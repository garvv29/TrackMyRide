import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/bus_stop.dart';
import '../services/bus_stops_service.dart';
import 'nearby_stops_map_screen.dart';

class NearbyBusStopsScreen extends StatefulWidget {
  NearbyBusStopsScreen({super.key});

  @override
  State<NearbyBusStopsScreen> createState() => _NearbyBusStopsScreenState();
}

class _NearbyBusStopsScreenState extends State<NearbyBusStopsScreen> {
  List<BusStop> _busStops = [];
  bool _isLoading = true;
  String? _errorMessage;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadNearbyStops();
  }

  Future<void> _loadNearbyStops() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔍 Starting nearby stops search...');
      
      // Get current location
      print('📍 Getting current location...');
      _currentPosition = await BusStopsService.getCurrentLocation();
      print('✅ Current location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      
      // Get nearby bus stops
      print('🚌 Searching for nearby bus stops within 10km...');
      List<BusStop> stops = await BusStopsService.getNearbyBusStops(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusKm: 10.0, // 10km radius
      );

      print('✅ Found ${stops.length} nearby stops');
      for (var stop in stops) {
        print('  - ${stop.stopName} (${stop.distance?.toStringAsFixed(2)}km)');
      }

      setState(() {
        _busStops = stops;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading nearby stops: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Bus Stops'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Map view button
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              if (_busStops.isNotEmpty && _currentPosition != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NearbyStopsMapScreen(
                      busStops: _busStops,
                      currentLocation: _currentPosition!,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Loading stops data...')),
                );
              }
            },
            tooltip: 'Map View',
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyStops,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading nearby bus stops...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading bus stops',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNearbyStops,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_busStops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No bus stops found nearby',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try expanding your search radius',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNearbyStops,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNearbyStops,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _busStops.length,
        itemBuilder: (context, index) {
          return _buildBusStopCard(_busStops[index]);
        },
      ),
    );
  }

  Widget _buildBusStopCard(BusStop busStop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showBusStopDetails(busStop),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stop name and distance
              Row(
                children: [
                  Expanded(
                    child: Text(
                      busStop.stopName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (busStop.distance != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${busStop.distance!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // City and state
              Row(
                children: [
                  Icon(
                    Icons.location_city,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${busStop.city}, ${busStop.state}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              // Address if available
              if (busStop.address != null && busStop.address!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.place,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        busStop.address!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openInMaps(busStop),
                      icon: const Icon(Icons.directions, size: 16),
                      label: Text(
                        'Directions',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showBusStopDetails(busStop),
                      icon: const Icon(Icons.info, size: 16),
                      label: Text(
                        'Details',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBusStopDetails(BusStop busStop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Stop name
              Text(
                busStop.stopName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Details list
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailRow(
                      Icons.location_city,
                      'City',
                      busStop.city,
                    ),
                    _buildDetailRow(
                      Icons.map,
                      'State',
                      busStop.state,
                    ),
                    if (busStop.address != null && busStop.address!.isNotEmpty)
                      _buildDetailRow(
                        Icons.place,
                        'Address',
                        busStop.address!,
                      ),
                    if (busStop.distance != null)
                      _buildDetailRow(
                        Icons.near_me,
                        'Distance',
                        '${busStop.distance!.toStringAsFixed(2)} km',
                      ),
                    _buildDetailRow(
                      Icons.gps_fixed,
                      'Coordinates',
                      '${busStop.latitude.toStringAsFixed(6)}, ${busStop.longitude.toStringAsFixed(6)}',
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openInMaps(busStop),
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        if (_currentPosition != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NearbyStopsMapScreen(
                                busStops: [busStop],
                                currentLocation: _currentPosition!,
                                selectedStop: busStop,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('View on Map'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openInMaps(BusStop busStop) {
    // TODO: Implement opening in maps app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening directions to ${busStop.stopName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}