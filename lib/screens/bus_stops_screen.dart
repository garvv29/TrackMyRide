import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../services/bus_stops_service.dart';
import '../models/bus_stop.dart' as bus_stop_model;

class BusStopsScreen extends StatefulWidget {
  final Bus bus;

  const BusStopsScreen({
    super.key,
    required this.bus,
  });

  @override
  State<BusStopsScreen> createState() => _BusStopsScreenState();
}

class _BusStopsScreenState extends State<BusStopsScreen> {
  List<bus_stop_model.BusStop> _stops = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStops();
  }

  Future<void> _loadStops() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stops = await BusStopsService.getAllBusStops();
      setState(() {
        _stops = stops;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load bus stops: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus ${widget.bus.busNumber} - All Stops'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Route Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.bus.from} → ${widget.bus.to}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.bus.departureTime} - ${widget.bus.arrivalTime} • ${widget.bus.duration}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Stops List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadStops,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _stops.isEmpty
                        ? const Center(child: Text('No bus stops found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _stops.length,
                            itemBuilder: (context, index) {
                              final stop = _stops[index];
                              final isLast = index == _stops.length - 1;
                              
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Timeline indicator
                                  Column(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      if (!isLast)
                                        Container(
                                          width: 2,
                                          height: 50,
                                          color: Colors.grey.shade300,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Stop details
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stop.stopName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (stop.address?.isNotEmpty == true) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              stop.address!,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                          if (stop.stopCode?.isNotEmpty == true) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'Stop Code: ${stop.stopCode}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

}