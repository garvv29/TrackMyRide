import 'package:flutter/material.dart';
import '../services/route_service.dart';
import 'route_details_screen.dart';

class BusSearchResultsScreen extends StatefulWidget {
  final String from;
  final String to;
  final String fromId;
  final String toId;

  const BusSearchResultsScreen({
    super.key,
    required this.from,
    required this.to,
    required this.fromId,
    required this.toId,
  });

  @override
  State<BusSearchResultsScreen> createState() => _BusSearchResultsScreenState();
}

class _BusSearchResultsScreenState extends State<BusSearchResultsScreen> {
  List<BusRoute> _routes = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchRoutes();
  }

  Future<void> _searchRoutes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('BusSearchResultsScreen: Searching routes from ${widget.from} to ${widget.to}');
      final routes = await RouteService.searchRoutes(
        from: widget.from,
        to: widget.to,
      );
      print('BusSearchResultsScreen: Received ${routes.length} routes');
      for (int i = 0; i < routes.length; i++) {
        print('Route $i: ${routes[i].routeName} - ${routes[i].routeNumber}');
      }
      if (mounted) {
        setState(() {
          _routes = routes; // Use BusRoute objects directly
          _isLoading = false;
        });
      }
    } catch (e) {
      print('BusSearchResultsScreen: Error - $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _searchRoutes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Searching for routes...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load routes',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _searchRoutes,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _routes.isEmpty
                  ? const Center(child: Text('No routes found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _routes.length,
                      itemBuilder: (context, index) {
                        final bus = _routes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Route ${bus.routeNumber}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${bus.startLocation} → ${bus.endLocation}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Route Name: ${bus.routeName}'),
                                Text('Duration: ${bus.estimatedDuration} minutes'),
                                Text('Distance: ${bus.totalDistance.toStringAsFixed(1)} km'),
                                Text('Type: ${bus.routeType}'),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RouteDetailsScreen(route: bus),
                                            ),
                                          );
                                        },
                                        child: const Text('View Route Details'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          // Navigate to route details with map view enabled
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RouteDetailsScreen(
                                                route: bus,
                                                showMapInitially: true, // Open map view directly
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('View on Map'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}