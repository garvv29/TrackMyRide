import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/route_service.dart';
import '../services/routing_service.dart';
import '../services/live_tracking_service.dart';
import '../models/bus_tracking_models.dart';
import '../services/map_performance_service.dart';

class RouteDetailsScreen extends StatefulWidget {
  final BusRoute route;
  final bool showMapInitially;

  const RouteDetailsScreen({
    Key? key, 
    required this.route,
    this.showMapInitially = false,
  }) : super(key: key);

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  final RouteService _routeService = RouteService();
  final LiveTrackingService _trackingService = LiveTrackingService();
  
  List<RouteStop> stops = [];
  bool isLoading = true;
  String? error;
  
  // Map related variables
  MapController _mapController = MapController();
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  bool _showMap = false;
  
  // Live tracking variables
  LiveBusData? _currentBusData;
  List<StopTiming> _stopTimings = [];
  RouteProgress? _routeProgress;
  bool _isTrackingActive = false;

  @override
  void initState() {
    super.initState();
    
    // Set initial view based on parameter
    _showMap = widget.showMapInitially;
    
    _loadRouteStops();
  }

  Future<void> _loadRouteStops() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('RouteDetailsScreen: Loading stops for route ID: ${widget.route.id}');
      final routeStops = await _routeService.getRouteStops(widget.route.id);
      
      setState(() {
        stops = routeStops;
        isLoading = false;
      });
      
      // Create map markers after stops are loaded
      _createMapMarkers();
      
      // Don't auto-start tracking - let user control it manually
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _createMapMarkers() async {
    _markers.clear();
    _polylines.clear();
    
    print('DEBUG: Creating map markers for route: ${widget.route.routeName}');
    print('DEBUG: Route start coordinates: ${widget.route.startLatitude}, ${widget.route.startLongitude}');
    print('DEBUG: Route end coordinates: ${widget.route.endLatitude}, ${widget.route.endLongitude}');
    print('DEBUG: Total stops to process: ${stops.length}');
    
    List<LatLng> waypoints = [];
    
    // Add start location marker (GREEN for start)
    if (widget.route.startLatitude != 0 && widget.route.startLongitude != 0) {
      final startPoint = LatLng(widget.route.startLatitude, widget.route.startLongitude);
      waypoints.add(startPoint);
      
      _markers.add(
        Marker(
          point: startPoint,
          child: Container(
            child: const Icon(
              Icons.location_on,
              color: Colors.green, // GREEN for start (Railway Station)
              size: 35,
            ),
          ),
        ),
      );
      print('DEBUG: Added start marker (GREEN) at Railway Station: ${startPoint.latitude}, ${startPoint.longitude}');
    }
    
    // Add bus stop markers and collect waypoints
    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final coordinates = stop.stopDetails.coordinates;
      
      // Handle both regular coordinates and Firestore GeoPoint format
      double? lat, lng;
      
      if (coordinates['_latitude'] != null && coordinates['_longitude'] != null) {
        // Firestore GeoPoint format
        lat = (coordinates['_latitude'] as num?)?.toDouble();
        lng = (coordinates['_longitude'] as num?)?.toDouble();
      } else if (coordinates['latitude'] != null && coordinates['longitude'] != null) {
        // Regular format
        lat = (coordinates['latitude'] as num?)?.toDouble();
        lng = (coordinates['longitude'] as num?)?.toDouble();
      }
      
      if (lat != null && lng != null) {
        final stopPoint = LatLng(lat, lng);
        waypoints.add(stopPoint);
        
        print('DEBUG: Adding stop marker at ${stop.stopDetails.stopName}: $lat, $lng');
        
        // Find timing info for this stop
        StopTiming? timing;
        if (_stopTimings.isNotEmpty && i < _stopTimings.length) {
          timing = _stopTimings[i];
        }
        
        _markers.add(
          Marker(
            point: stopPoint,
            child: _buildStopMarker(stop, timing),
          ),
        );
      } else {
        print('DEBUG: Invalid coordinates for stop ${stop.stopDetails.stopName}: $coordinates');
      }
    }
    
    // Add end location marker (RED for destination)
    if (widget.route.endLatitude != 0 && widget.route.endLongitude != 0) {
      final endPoint = LatLng(widget.route.endLatitude, widget.route.endLongitude);
      waypoints.add(endPoint);
      
      _markers.add(
        Marker(
          point: endPoint,
          child: Container(
            child: const Icon(
              Icons.location_on,
              color: Colors.red, // RED for end (Magneto Mall)
              size: 35,
            ),
          ),
        ),
      );
      print('DEBUG: Added end marker (RED) at Magneto Mall: ${endPoint.latitude}, ${endPoint.longitude}');
    }
    
    // Add current bus marker (if tracking is active)
    if (_currentBusData != null) {
      _markers.add(
        Marker(
          point: _currentBusData!.currentLocation,
          child: _buildBusMarker(_currentBusData!),
        ),
      );
    }
    
    // Create road-following route using OSRM
    if (waypoints.length >= 2) {
      try {
        print('Creating road-based route with ${waypoints.length} waypoints...');
        
        // Get actual road route points
        final routePoints = await RoutingService.getMultiWaypointRoute(waypoints);
        
        print('Received ${routePoints.length} route points from OSRM');
        
        if (routePoints.isNotEmpty) {
          // Add shadow effect for depth
          _polylines.add(
            Polyline(
              points: routePoints,
              color: Colors.black.withOpacity(0.3),
              strokeWidth: 7.0,
            ),
          );
          
          // Add main route polyline with road-following style
          _polylines.add(
            Polyline(
              points: routePoints,
              color: const Color(0xFF2196F3), // Blue for main route
              strokeWidth: 5.0,
            ),
          );
          
          print('✅ Road-following route created with ${routePoints.length} points');
          
          // Update the UI to show the new route
          if (mounted) {
            setState(() {});
          }
        } else {
          print('⚠️ No route points received, creating fallback direct route');
          // Fallback to direct lines between waypoints
          _polylines.add(
            Polyline(
              points: waypoints,
              color: Colors.grey.withOpacity(0.8),
              strokeWidth: 3.0,
            ),
          );
        }
      } catch (e) {
        print('Error creating road route: $e');
        
        // Fallback to direct line if routing fails
        _polylines.add(
          Polyline(
            points: waypoints,
            color: Colors.blue.withOpacity(0.7),
            strokeWidth: 3.0,
          ),
        );
        
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.route.routeName),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Live tracking toggle
          IconButton(
            icon: Icon(_isTrackingActive ? Icons.stop : Icons.live_tv),
            onPressed: _toggleLiveTracking,
            tooltip: _isTrackingActive ? 'Stop Tracking' : 'Live Tracking',
          ),
          // Map/List view toggle
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
            tooltip: _showMap ? 'List View' : 'Map View',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _buildErrorWidget()
              : _showMap ? _buildMapView() : _buildRouteDetails(),
    );
  }

  Widget _buildErrorWidget() {
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
            'Error Loading Data',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRouteStops,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route Info Card
          _buildRouteInfoCard(),
          const SizedBox(height: 16),
          
          // Tracking Status & View Map Button
          _buildActionButtons(),
          const SizedBox(height: 24),
          
          // Stops Section
          _buildStopsSection(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Live Tracking Status
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isTrackingActive ? Colors.green.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isTrackingActive ? Colors.green : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isTrackingActive ? Icons.live_tv : Icons.tv_off,
                color: _isTrackingActive ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isTrackingActive ? 'Live Tracking Active' : 'Live Tracking Inactive',
                  style: TextStyle(
                    color: _isTrackingActive ? Colors.green.shade700 : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: _toggleLiveTracking,
                child: Text(_isTrackingActive ? 'Stop' : 'Start'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // View on Map Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showMap = true;
              });
            },
            icon: const Icon(Icons.map),
            label: const Text('View on Map'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.route.routeName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Route Number: ${widget.route.routeNumber}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.location_on,
                    label: 'From',
                    value: widget.route.startLocation,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.location_on,
                    label: 'To',
                    value: widget.route.endLocation,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.timer,
                    label: 'Duration',
                    value: '${widget.route.estimatedDuration} min',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: '${widget.route.totalDistance.toStringAsFixed(1)} km',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStopsSection() {
    final busStops = stops.where((stop) => stop.busStopsHere).length;
    final minorStops = stops.where((stop) => !stop.busStopsHere).length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.alt_route,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Route Stops',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatsChip(
              icon: Icons.bus_alert,
              label: 'Bus Stops',
              count: busStops,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _buildStatsChip(
              icon: Icons.location_on_outlined,
              label: 'Minor Stops',
              count: minorStops,
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStopsTimeline(),
      ],
    );
  }

  Widget _buildStatsChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text('$count $label'),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildStopsTimeline() {
    if (stops.isEmpty) {
      return const Center(
        child: Text('No stops found for this route'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stops.length,
      itemBuilder: (context, index) {
        final stop = stops[index];
        final isLast = index == stops.length - 1;
        
        return _buildStopItem(stop, isLast);
      },
    );
  }

  Widget _buildStopItem(RouteStop stop, bool isLast) {
    final isBusStop = stop.busStopsHere;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isBusStop ? Colors.green : Colors.orange,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isBusStop ? Icons.directions_bus : Icons.circle,
                  size: isBusStop ? 12 : 8,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Stop Details
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stop.stopDetails.stopName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isBusStop)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'No Stop',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stop.stopDetails.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (isBusStop) ...[
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Scheduled timing
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Scheduled: ${stop.arrivalTime}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // Expected timing with delay (if any)
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: _getDelayColor(2), // Sample delay
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Expected: ${_calculateExpectedTime(stop.arrivalTime, 2)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getDelayColor(2),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDelayColor(2).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getDelayColor(2).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '+2 min',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getDelayColor(2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    if (stop.stopDetails.amenities.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: stop.stopDetails.amenities
                            .take(3)
                            .map((amenity) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    amenity,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    // Default center - use route start coordinates or Raipur center
    LatLng center = const LatLng(21.2497, 81.6947); // Raipur Railway Station
    
    if (widget.route.startLatitude != 0 && widget.route.startLongitude != 0) {
      center = LatLng(widget.route.startLatitude, widget.route.startLongitude);
    }

    return Column(
      children: [
        // Route info header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Column(
            children: [
              Text(
                widget.route.routeName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.route.startLocation} → ${widget.route.endLocation}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              // Live tracking progress bar
              if (_isTrackingActive && _routeProgress != null) ...[
                const SizedBox(height: 12),
                _buildProgressIndicator(),
              ],
              
              if (stops.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMapStat('Total Stops', stops.length.toString()),
                    _buildMapStat('Bus Stops', stops.where((s) => s.busStopsHere).length.toString()),
                    _buildMapStat('Distance', '${widget.route.totalDistance} km'),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Map
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapPerformanceService.getOptimizedMapOptions(center: center),
            children: [
              MapPerformanceService.getOptimizedTileLayer(),
              PolylineLayer(
                polylines: _polylines,
              ),
              MarkerLayer(
                markers: MapPerformanceService.optimizeMarkers(_markers, 12.0),
              ),
            ],
          ),
        ),
        // Map legend
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.grey[100],
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildMapLegend(Colors.green, 'Start'),
              _buildMapLegend(Colors.red, 'End'),
              _buildMapLegend(Colors.blue, 'Bus Stop'),
              _buildMapLegend(Colors.orange, 'Minor Stop'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  /// Build route progress indicator
  Widget _buildProgressIndicator() {
    if (_routeProgress == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Route Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _routeProgress!.progressText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _routeProgress!.completedPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _routeProgress!.totalDelay.inMinutes > 5 
                            ? Colors.red 
                            : _routeProgress!.totalDelay.inMinutes > 0 
                                ? Colors.orange 
                                : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressStat(
                'Distance',
                _routeProgress!.distanceText,
                Icons.straighten,
              ),
              _buildProgressStat(
                'ETA',
                _routeProgress!.etaText,
                Icons.access_time,
              ),
              _buildProgressStat(
                'Status',
                _routeProgress!.delayText,
                _routeProgress!.totalDelay.inMinutes > 0 ? Icons.schedule : Icons.check_circle,
                color: _routeProgress!.totalDelay.inMinutes > 5 
                    ? Colors.red 
                    : _routeProgress!.totalDelay.inMinutes > 0 
                        ? Colors.orange 
                        : Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build individual progress stat
  Widget _buildProgressStat(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Colors.grey[600],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMapLegend(Color color, String label) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 9),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build enhanced stop marker with timing information
  Widget _buildStopMarker(RouteStop stop, StopTiming? timing) {
    return GestureDetector(
      onTap: () => _showStopDetails(stop, timing),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timing badge (if available)
            if (timing != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: timing.statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  timing.isPassed ? 'Passed' : timing.estimatedArrival.hour.toString().padLeft(2, '0') + ':' + 
                    timing.estimatedArrival.minute.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
            ],
            // Stop icon
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: stop.busStopsHere ? Colors.blue : Colors.orange,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                stop.busStopsHere ? Icons.directions_bus : Icons.place,
                color: stop.busStopsHere ? Colors.blue : Colors.orange,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build live bus marker
  Widget _buildBusMarker(LiveBusData busData) {
    return GestureDetector(
      onTap: () => _showBusDetails(busData),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Speed badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getSpeedColor(busData.speed),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${busData.speed.toInt()} km/h',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Bus icon with animation
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Get color based on speed
  Color _getSpeedColor(double speed) {
    if (speed < 5) return Colors.red;
    if (speed < 15) return Colors.orange;
    if (speed < 30) return Colors.green;
    return Colors.blue;
  }
  
  /// Show stop details dialog
  void _showStopDetails(RouteStop stop, StopTiming? timing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(stop.stopDetails.stopName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stop Code: ${stop.stopDetails.stopCode}'),
            Text('Type: ${stop.busStopsHere ? "Bus Stop" : "Minor Stop"}'),
            if (stop.stopDetails.address.isNotEmpty)
              Text('Address: ${stop.stopDetails.address}'),
            if (timing != null) ...[
              const SizedBox(height: 8),
              const Divider(),
              const Text('Timing Information', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Scheduled: ${timing.scheduledArrival.hour}:${timing.scheduledArrival.minute.toString().padLeft(2, '0')}'),
              Text('Estimated: ${timing.estimatedArrival.hour}:${timing.estimatedArrival.minute.toString().padLeft(2, '0')}'),
              Text('Status: ${timing.statusText}'),
              if (!timing.isPassed)
                Text('Distance: ${timing.distanceFromBus.toStringAsFixed(1)} km'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  /// Show bus details dialog
  void _showBusDetails(LiveBusData busData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bus ${busData.busId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Speed: ${busData.speed.toStringAsFixed(1)} km/h'),
            Text('Direction: ${busData.direction}'),
            Text('Passengers: ${busData.passengerCount}'),
            Text('Battery: ${busData.batteryLevel.toStringAsFixed(1)}%'),
            Text('Last Update: ${busData.lastUpdate.hour}:${busData.lastUpdate.minute.toString().padLeft(2, '0')}'),
            Text('Status: ${busData.isOnline ? "Online" : "Offline"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  /// Start live tracking
  void _startLiveTracking() async {
    if (_isTrackingActive) return;
    
    setState(() {
      _isTrackingActive = true;
    });
    
    try {
      await _trackingService.startTracking(widget.route.id, 'bus_raipur_001');
      
      // Listen to live data streams
      _trackingService.busDataStream?.listen((busData) {
        setState(() {
          _currentBusData = busData;
          _createMapMarkers(); // Update markers with bus position
        });
      });
      
      _trackingService.stopTimingsStream?.listen((timings) {
        setState(() {
          _stopTimings = timings;
          _createMapMarkers(); // Update markers with timing info
        });
      });
      
      _trackingService.progressStream?.listen((progress) {
        setState(() {
          _routeProgress = progress;
        });
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live tracking started'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error starting live tracking: $e');
      setState(() {
        _isTrackingActive = false;
      });
    }
  }
  
  /// Stop live tracking
  void _stopLiveTracking() {
    if (!_isTrackingActive) return;
    
    _trackingService.stopTracking();
    
    setState(() {
      _isTrackingActive = false;
      _currentBusData = null;
      _stopTimings.clear();
      _routeProgress = null;
    });
    
    _createMapMarkers(); // Remove bus marker
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live tracking stopped'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  /// Toggle live tracking
  void _toggleLiveTracking() {
    if (_isTrackingActive) {
      _stopLiveTracking();
    } else {
      _startLiveTracking();
    }
  }
  
  /// Get delay color based on delay minutes
  Color _getDelayColor(int delayMinutes) {
    if (delayMinutes == 0) {
      return Colors.green; // On time
    } else if (delayMinutes <= 2) {
      return Colors.orange; // Minor delay
    } else {
      return Colors.red; // Major delay
    }
  }
  
  /// Calculate expected time with delay
  String _calculateExpectedTime(String scheduledTime, int delayMinutes) {
    try {
      // Parse scheduled time (format: HH:MM)
      final parts = scheduledTime.split(':');
      if (parts.length != 2) return scheduledTime;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Add delay
      final totalMinutes = hour * 60 + minute + delayMinutes;
      final newHour = (totalMinutes ~/ 60) % 24;
      final newMinute = totalMinutes % 60;
      
      return '${newHour.toString().padLeft(2, '0')}:${newMinute.toString().padLeft(2, '0')}';
    } catch (e) {
      return scheduledTime; // Return original if parsing fails
    }
  }
  
  @override
  void dispose() {
    _trackingService.dispose();
    super.dispose();
  }
}