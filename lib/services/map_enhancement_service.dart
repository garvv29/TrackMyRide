import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/osm_config.dart';

class MapEnhancementService {
  // Enhanced tile layer with multiple servers for reliability
  static TileLayer getReliableTileLayer({String style = 'standard'}) {
    final baseUrl = OSMConfig.mapStyles[style] ?? OSMConfig.mapStyles['standard']!;
    
    return TileLayer(
      urlTemplate: baseUrl,
      userAgentPackageName: 'com.example.track_my_bus',
      maxZoom: OSMConfig.maxZoom,
      tileSize: 256,
      retinaMode: true,
      // Fallback to different servers on error
      fallbackUrl: 'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
      errorTileCallback: (tile, error, stackTrace) {
        print('Map tile error: $error');
      },
    );
  }
  
  // Create enhanced polyline for routes
  static Polyline createRoutePolyline(
    List<LatLng> points, {
    Color? color,
    double width = 4.0,
  }) {
    return Polyline(
      points: points,
      color: color ?? const Color(0xFF2196F3),
      strokeWidth: width,
    );
  }
  
  // Create enhanced markers with custom styles
  static Marker createEnhancedMarker(
    LatLng point,
    String type, {
    String? label,
    VoidCallback? onTap,
  }) {
    final style = OSMConfig.markerStyles[type] ?? OSMConfig.markerStyles['bus_stop']!;
    
    return Marker(
      point: point,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: style.size,
          height: style.size,
          decoration: BoxDecoration(
            color: style.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getIconData(style.icon),
            color: Colors.white,
            size: style.size * 0.6,
          ),
        ),
      ),
    );
  }
  
  // Create animated bus marker
  static Widget createAnimatedBusMarker({
    required bool isMoving,
    double size = 40,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isMoving ? Colors.green : Colors.orange,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: (isMoving ? Colors.green : Colors.orange).withOpacity(0.5),
            blurRadius: isMoving ? 8 : 4,
            spreadRadius: isMoving ? 2 : 0,
          ),
        ],
      ),
      child: Icon(
        Icons.directions_bus,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
  
  // Create map legend widget
  static Widget createMapLegend() {
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Map Legend',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(Colors.green, 'Start Point'),
          _buildLegendItem(Colors.red, 'End Point'),
          _buildLegendItem(Colors.blue, 'Major Stop'),
          _buildLegendItem(Colors.orange, 'Minor Stop'),
          _buildLegendItem(Colors.purple, 'Bus Location'),
        ],
      ),
    );
  }
  
  // Create map controls widget
  static Widget createMapControls({
    required VoidCallback onZoomIn,
    required VoidCallback onZoomOut,
    required VoidCallback onRecenter,
    VoidCallback? onToggleStyle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildControlButton(Icons.add, onZoomIn, 'Zoom In'),
        const SizedBox(height: 4),
        _buildControlButton(Icons.remove, onZoomOut, 'Zoom Out'),
        const SizedBox(height: 4),
        _buildControlButton(Icons.my_location, onRecenter, 'Recenter'),
        if (onToggleStyle != null) ...[
          const SizedBox(height: 4),
          _buildControlButton(Icons.layers, onToggleStyle, 'Toggle Style'),
        ],
      ],
    );
  }
  
  // Calculate optimal map bounds for given points
  static LatLngBounds calculateOptimalBounds(List<LatLng> points) {
    if (points.isEmpty) return OSMConfig.raipurBounds;
    
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    
    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }
    
    // Add padding
    const padding = 0.001;
    return LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    );
  }
  
  // Get appropriate zoom level for bounds
  static double calculateOptimalZoom(LatLngBounds bounds) {
    final latDiff = bounds.north - bounds.south;
    final lngDiff = bounds.east - bounds.west;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    
    if (maxDiff > 0.1) return 10.0;
    if (maxDiff > 0.05) return 11.0;
    if (maxDiff > 0.02) return 12.0;
    if (maxDiff > 0.01) return 13.0;
    if (maxDiff > 0.005) return 14.0;
    return 15.0;
  }
  
  // Private helper methods
  static IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'location_on':
        return Icons.location_on;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'circle':
        return Icons.circle;
      default:
        return Icons.location_on;
    }
  }
  
  static Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  static Widget _buildControlButton(
    IconData icon,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return Container(
      width: 40,
      height: 40,
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
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }
}