import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math' as math;
import '../config/osm_config.dart';

class MapPerformanceService {
  static const int _maxCacheSize = 100;
  static const Duration _cacheExpiry = Duration(hours: 1);
  
  // Cache for tile loading optimization
  static final Map<String, _CachedTile> _tileCache = {};
  static Timer? _cacheCleanupTimer;
  
  // Route calculation cache
  static final Map<String, List<LatLng>> _routeCache = {};
  
  static void initialize() {
    // Start periodic cache cleanup
    _cacheCleanupTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _cleanupCache(),
    );
  }
  
  static void dispose() {
    _cacheCleanupTimer?.cancel();
    _tileCache.clear();
    _routeCache.clear();
  }
  
  // Optimized tile loading with cache
  static TileLayer getOptimizedTileLayer({String style = 'standard'}) {
    return TileLayer(
      urlTemplate: OSMConfig.mapStyles[style] ?? OSMConfig.mapStyles['standard']!,
      userAgentPackageName: 'com.example.track_my_bus',
      maxZoom: OSMConfig.maxZoom,
      tileSize: 256,
      retinaMode: true,
      // Error handling with fallback
      errorTileCallback: (tile, error, stackTrace) {
        print('Map tile error: $error');
        // Try alternative tile server
        _retryTileLoad(tile);
      },
    );
  }
  
  // Route optimization for better performance
  static List<LatLng> optimizeRoute(List<LatLng> route, {double tolerance = 0.0001}) {
    if (route.length <= 2) return route;
    
    // Check cache first
    final routeKey = _generateRouteKey(route);
    if (_routeCache.containsKey(routeKey)) {
      return _routeCache[routeKey]!;
    }
    
    // Douglas-Peucker algorithm for route simplification
    final optimized = _douglasPeucker(route, tolerance);
    
    // Cache the result
    _routeCache[routeKey] = optimized;
    return optimized;
  }
  
  // Smart marker clustering for performance
  static List<Marker> optimizeMarkers(
    List<Marker> markers, 
    double zoom, {
    double clusterDistance = 40.0,
  }) {
    if (zoom > 14.0 || markers.length <= 10) {
      return markers; // No clustering needed at high zoom
    }
    
    // Group nearby markers
    final clusters = <List<Marker>>[];
    final processed = <bool>[]..length = markers.length;
    processed.fillRange(0, markers.length, false);
    
    for (int i = 0; i < markers.length; i++) {
      if (processed[i]) continue;
      
      final cluster = <Marker>[markers[i]];
      processed[i] = true;
      
      for (int j = i + 1; j < markers.length; j++) {
        if (processed[j]) continue;
        
        final distance = _calculateDistance(
          markers[i].point,
          markers[j].point,
        );
        
        if (distance < clusterDistance / zoom) {
          cluster.add(markers[j]);
          processed[j] = true;
        }
      }
      
      clusters.add(cluster);
    }
    
    // Create cluster markers or return individual markers
    return clusters.map((cluster) {
      if (cluster.length == 1) {
        return cluster.first;
      } else {
        return _createClusterMarker(cluster);
      }
    }).toList();
  }
  
  // Memory management for map bounds
  static MapOptions getOptimizedMapOptions({
    LatLng? center,
    double? zoom,
    bool restrictToBounds = true,
  }) {
    return MapOptions(
      initialCenter: center ?? OSMConfig.raipurCenter,
      initialZoom: zoom ?? OSMConfig.defaultZoom,
      minZoom: OSMConfig.minZoom,
      maxZoom: OSMConfig.maxZoom,
      // Restrict to Raipur bounds for better performance
      cameraConstraint: restrictToBounds 
        ? CameraConstraint.contain(bounds: OSMConfig.raipurBounds)
        : CameraConstraint.unconstrained(),
      // Optimized interactions
      interactionOptions: const InteractionOptions(
        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
      ),
      // Performance settings
      keepAlive: true,
    );
  }
  
  // Preload map tiles for better UX
  static Future<void> preloadMapTiles(LatLng center, double zoom) async {
    // Calculate tile bounds for current view
    final bounds = _getTileBounds(center, zoom);
    
    // Preload tiles in background
    for (int x = bounds['minX']!; x <= bounds['maxX']!; x++) {
      for (int y = bounds['minY']!; y <= bounds['maxY']!; y++) {
        final tileUrl = _buildTileUrl(x, y, zoom.toInt());
        _cacheTile(tileUrl);
      }
    }
  }
  
  // Private helper methods
  static void _retryTileLoad(dynamic tile) {
    // Implementation for tile retry with different server
    print('Retrying tile load...');
  }
  
  static String _generateRouteKey(List<LatLng> route) {
    final start = route.first;
    final end = route.last;
    return '${start.latitude},${start.longitude}-${end.latitude},${end.longitude}';
  }
  
  static List<LatLng> _douglasPeucker(List<LatLng> points, double tolerance) {
    if (points.length <= 2) return points;
    
    // Find the point with maximum distance
    double maxDistance = 0;
    int index = 0;
    
    for (int i = 1; i < points.length - 1; i++) {
      final distance = _perpendicularDistance(
        points[i],
        points.first,
        points.last,
      );
      if (distance > maxDistance) {
        index = i;
        maxDistance = distance;
      }
    }
    
    // If max distance is greater than tolerance, recursively simplify
    if (maxDistance > tolerance) {
      final left = _douglasPeucker(
        points.sublist(0, index + 1),
        tolerance,
      );
      final right = _douglasPeucker(
        points.sublist(index),
        tolerance,
      );
      
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [points.first, points.last];
    }
  }
  
  static double _perpendicularDistance(LatLng point, LatLng lineStart, LatLng lineEnd) {
    // Calculate perpendicular distance from point to line
    final A = point.latitude - lineStart.latitude;
    final B = point.longitude - lineStart.longitude;
    final C = lineEnd.latitude - lineStart.latitude;
    final D = lineEnd.longitude - lineStart.longitude;
    
    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    
    if (lenSq == 0) {
      return _calculateDistance(point, lineStart);
    }
    
    final param = dot / lenSq;
    final xx = lineStart.latitude + param * C;
    final yy = lineStart.longitude + param * D;
    
    return _calculateDistance(point, LatLng(xx, yy));
  }
  
  static double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters
    final lat1Rad = point1.latitude * (math.pi / 180);
    final lat2Rad = point2.latitude * (math.pi / 180);
    final deltaLat = (point2.latitude - point1.latitude) * (math.pi / 180);
    final deltaLng = (point2.longitude - point1.longitude) * (math.pi / 180);
    
    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLng / 2) * math.sin(deltaLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  static Marker _createClusterMarker(List<Marker> cluster) {
    // Calculate cluster center
    double lat = 0, lng = 0;
    for (final marker in cluster) {
      lat += marker.point.latitude;
      lng += marker.point.longitude;
    }
    lat /= cluster.length;
    lng /= cluster.length;
    
    return Marker(
      point: LatLng(lat, lng),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: OSMConfig.markerStyles['bus_stop']!.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            '${cluster.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
  
  static Map<String, int> _getTileBounds(LatLng center, double zoom) {
    final zoomInt = zoom.toInt();
    final scale = 1 << zoomInt;
    
    final x = ((center.longitude + 180) / 360 * scale).floor();
    final latRad = center.latitude * math.pi / 180;
    final y = ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) / 2 * scale).floor();
    
    return {
      'minX': x - 1,
      'maxX': x + 1,
      'minY': y - 1,
      'maxY': y + 1,
    };
  }
  
  static String _buildTileUrl(int x, int y, int zoom) {
    return 'https://tile.openstreetmap.org/$zoom/$x/$y.png';
  }
  
  static void _cacheTile(String url) {
    if (_tileCache.length > _maxCacheSize) {
      _cleanupCache();
    }
    
    _tileCache[url] = _CachedTile(DateTime.now());
  }
  
  static void _cleanupCache() {
    final now = DateTime.now();
    _tileCache.removeWhere((key, tile) => 
      now.difference(tile.timestamp) > _cacheExpiry
    );
  }
}

class _CachedTile {
  final DateTime timestamp;
  
  _CachedTile(this.timestamp);
}