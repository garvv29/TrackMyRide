import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/bus_stop.dart';

class NearbyStopsMapScreen extends StatefulWidget {
  final List<BusStop> busStops;
  final Position currentLocation;
  final BusStop? selectedStop;

  NearbyStopsMapScreen({
    super.key,
    required this.busStops,
    required this.currentLocation,
    this.selectedStop,
  });

  @override
  State<NearbyStopsMapScreen> createState() => _NearbyStopsMapScreenState();
}

class _NearbyStopsMapScreenState extends State<NearbyStopsMapScreen> {
  BusStop? _selectedStop;

  @override
  void initState() {
    super.initState();
    _selectedStop = widget.selectedStop;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Stops Map'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.pop(context),
            tooltip: 'List View',
          ),
        ],
      ),
      body: Column(
        children: [
          // Map placeholder (since we don't have google_maps yet)
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Interactive Map',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Showing ${widget.busStops.length} bus stops',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Location: ${widget.currentLocation.latitude.toStringAsFixed(6)}, ${widget.currentLocation.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bus stops list at bottom
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          'Bus Stops',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${widget.busStops.length} stops',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Bus stops list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: widget.busStops.length,
                      itemBuilder: (context, index) {
                        final stop = widget.busStops[index];
                        final isSelected = _selectedStop?.id == stop.id;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected 
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.directions_bus,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              stop.stopName,
                              style: TextStyle(
                                fontWeight: isSelected 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${stop.city}, ${stop.state}'),
                                if (stop.distance != null)
                                  Text('${stop.distance!.toStringAsFixed(1)} km away'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isSelected ? Icons.visibility : Icons.visibility_outlined,
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedStop = isSelected ? null : stop;
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                _selectedStop = isSelected ? null : stop;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Floating action buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Center on user location
          FloatingActionButton(
            mini: true,
            heroTag: 'center_location',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Centering on your location'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Icon(Icons.my_location),
          ),
          
          const SizedBox(height: 8),
          
          // Show all stops
          FloatingActionButton(
            mini: true,
            heroTag: 'show_all',
            onPressed: () {
              setState(() {
                _selectedStop = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Showing all bus stops'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Icon(Icons.zoom_out_map),
          ),
        ],
      ),
    );
  }
}