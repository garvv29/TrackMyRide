import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OSMConfig {
  // OpenStreetMap tile servers (multiple for reliability)
  static const List<String> tileServers = [
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://b.tile.openstreetmap.org/{z}/{x}/{y}.png',
    'https://c.tile.openstreetmap.org/{z}/{x}/{y}.png',
  ];
  
  // Different map styles available
  static const Map<String, String> mapStyles = {
    'standard': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'humanitarian': 'https://tile-{s}.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    'transport': 'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png',
    'landscape': 'https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png',
  };
  
  // Raipur specific bounds
  static final LatLngBounds raipurBounds = LatLngBounds(
    const LatLng(21.1800, 81.5500), // Southwest corner
    const LatLng(21.3200, 81.7500), // Northeast corner
  );
  
  // Default Raipur center
  static const LatLng raipurCenter = LatLng(21.2497, 81.6947); // Railway Station
  
  // Zoom levels
  static const double minZoom = 10.0;
  static const double maxZoom = 18.0;
  static const double defaultZoom = 12.0;
  
  // Map options for better performance
  static MapOptions getMapOptions({LatLng? center, double? zoom}) {
    return MapOptions(
      initialCenter: center ?? raipurCenter,
      initialZoom: zoom ?? defaultZoom,
      minZoom: minZoom,
      maxZoom: maxZoom,
      // Keep map within Raipur bounds for better UX
      cameraConstraint: CameraConstraint.contain(
        bounds: raipurBounds,
      ),
      // Smooth interactions
      interactionOptions: const InteractionOptions(
        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
      ),
    );
  }
  
  // Get tile layer with fallbacks
  static TileLayer getTileLayer({String style = 'standard'}) {
    return TileLayer(
      urlTemplate: mapStyles[style] ?? mapStyles['standard']!,
      userAgentPackageName: 'com.example.track_my_bus',
      maxZoom: maxZoom,
      // Better performance settings
      tileSize: 256,
      retinaMode: true,
      // Error handling
      errorTileCallback: (tile, error, stackTrace) {
        print('Map tile error: $error');
      },
    );
  }
  
  // Custom marker styles
  static const Map<String, MarkerStyle> markerStyles = {
    'start': MarkerStyle(
      color: Color(0xFF4CAF50), // Green
      size: 35,
      icon: 'location_on',
    ),
    'end': MarkerStyle(
      color: Color(0xFFF44336), // Red  
      size: 35,
      icon: 'location_on',
    ),
    'bus_stop': MarkerStyle(
      color: Color(0xFF2196F3), // Blue
      size: 30,
      icon: 'directions_bus',
    ),
    'minor_stop': MarkerStyle(
      color: Color(0xFFFF9800), // Orange
      size: 25,
      icon: 'circle',
    ),
    'bus': MarkerStyle(
      color: Color(0xFF9C27B0), // Purple
      size: 40,
      icon: 'directions_bus',
    ),
  };
  
  // Route polyline styles
  static const Map<String, PolylineStyle> polylineStyles = {
    'route': PolylineStyle(
      color: Color(0xFF2196F3),
      strokeWidth: 4.0,
    ),
    'bus_path': PolylineStyle(
      color: Color(0xFF4CAF50),
      strokeWidth: 3.0,
    ),
    'alternative': PolylineStyle(
      color: Color(0xFF757575),
      strokeWidth: 2.0,
    ),
  };
}

class MarkerStyle {
  final Color color;
  final double size;
  final String icon;
  
  const MarkerStyle({
    required this.color,
    required this.size,
    required this.icon,
  });
}

class PolylineStyle {
  final Color color;
  final double strokeWidth;
  
  const PolylineStyle({
    required this.color,
    required this.strokeWidth,
  });
}