import 'package:flutter/material.dart';
import '../models/bus.dart';

class MapViewScreen extends StatelessWidget {
  final Bus bus;

  const MapViewScreen({
    super.key,
    required this.bus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus ${bus.busNumber} - Route Map'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // TODO: Center map on user location
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Route Summary Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bus.from} → ${bus.to}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${bus.duration} • ${bus.stops.length} stops',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Map Placeholder (since we can't use actual Google Maps here)
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade100,
              child: Stack(
                children: [
                  // Mock Map Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE3F2FD),
                          Color(0xFFBBDEFB),
                        ],
                      ),
                    ),
                  ),
                  
                  // Mock Route Path
                  CustomPaint(
                    size: Size.infinite,
                    painter: RoutePathPainter(
                      theme: Theme.of(context),
                      stops: bus.stops,
                    ),
                  ),
                  
                  // Map Controls
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: "zoom_in",
                          onPressed: () {
                            // TODO: Zoom in
                          },
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: "zoom_out",
                          onPressed: () {
                            // TODO: Zoom out
                          },
                          child: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ),
                  
                  // Legend
                  Positioned(
                    left: 16,
                    bottom: 100,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Legend',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildLegendItem(
                              Colors.green,
                              'Start Point',
                            ),
                            _buildLegendItem(
                              Colors.blue,
                              'Bus Stops',
                            ),
                            _buildLegendItem(
                              Colors.red,
                              'End Point',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Info Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.access_time,
                  bus.duration,
                  'Duration',
                ),
                _buildInfoItem(
                  Icons.directions_bus,
                  bus.busType,
                  'Bus Type',
                ),
                _buildInfoItem(
                  Icons.repeat,
                  bus.frequency,
                  'Frequency',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class RoutePathPainter extends CustomPainter {
  final ThemeData theme;
  final List<String> stops;

  RoutePathPainter({
    required this.theme,
    required this.stops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Create a mock route path
    final startPoint = Offset(size.width * 0.2, size.height * 0.8);
    final endPoint = Offset(size.width * 0.8, size.height * 0.2);
    
    path.moveTo(startPoint.dx, startPoint.dy);
    
    // Add curves to simulate a realistic route
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.6,
      size.width * 0.5,
      size.height * 0.5,
    );
    
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.4,
      endPoint.dx,
      endPoint.dy,
    );
    
    canvas.drawPath(path, paint);
    
    // Draw stop markers
    final stopPaint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < stops.length; i++) {
      final t = i / (stops.length - 1);
      final point = _getPointOnPath(startPoint, endPoint, size, t);
      
      // Choose color based on position
      if (i == 0) {
        stopPaint.color = Colors.green;
      } else if (i == stops.length - 1) {
        stopPaint.color = Colors.red;
      } else {
        stopPaint.color = Colors.blue;
      }
      
      canvas.drawCircle(point, 6, stopPaint);
      
      // Draw white border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(point, 6, borderPaint);
    }
  }

  Offset _getPointOnPath(Offset start, Offset end, Size size, double t) {
    // Interpolate along the curved path
    final midX = start.dx + (end.dx - start.dx) * t;
    final midY = start.dy + (end.dy - start.dy) * t;
    
    // Add some curve variation
    final curveOffset = (1 - 4 * (t - 0.5) * (t - 0.5)) * 50;
    
    return Offset(midX + curveOffset * 0.5, midY - curveOffset * 0.3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}