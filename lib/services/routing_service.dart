import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  // Using OSRM (Open Source Routing Machine) - free alternative to Google Directions
  static const String _osrmBaseUrl = 'http://router.project-osrm.org/route/v1/driving';
  
  /// Get route points between two locations using OSRM with main roads preference
  static Future<List<LatLng>> getRoutePoints(LatLng start, LatLng end, {bool preferMainRoads = true}) async {
    try {
      // Build URL with routing preferences for main roads
      String url = '$_osrmBaseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
      url += '?geometries=geojson&overview=full&steps=true&alternatives=false';
      
      // Add routing preferences for main roads in India
      if (preferMainRoads) {
        url += '&exclude=ferry,toll'; // Exclude ferries and tolls for city routes
        url += '&annotations=nodes,distance,duration'; // Get detailed route info
      }
      
      print('Routing API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'TrackMyBus/1.0 (Raipur City Bus Tracking)',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          
          print('Route distance: ${route['distance']}m, duration: ${route['duration']}s');
          
          if (geometry != null && geometry['coordinates'] != null) {
            final List<dynamic> coordinates = geometry['coordinates'];
            
            // Convert coordinates to LatLng points
            List<LatLng> routePoints = coordinates.map((coord) {
              return LatLng(coord[1].toDouble(), coord[0].toDouble()); // Note: OSRM returns [lng, lat]
            }).toList();
            
            // Enhanced filtering for better road representation
            List<LatLng> filteredPoints = _enhancedFilterRoutePoints(routePoints);
            
            print('✅ Route points received: ${routePoints.length}, filtered: ${filteredPoints.length}');
            return filteredPoints;
          }
        }
      } else {
        print('❌ Routing API failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting route: $e');
    }
    
    print('⚠️ Falling back to direct line between points');
    // Fallback to direct line if routing fails
    return [start, end];
  }
  
  /// Enhanced filter route points for better road representation
  static List<LatLng> _enhancedFilterRoutePoints(List<LatLng> points) {
    if (points.length <= 10) return points; // Keep all points for short routes
    
    List<LatLng> filtered = [points.first]; // Always keep first point
    
    double totalDistance = 0;
    for (int i = 1; i < points.length; i++) {
      totalDistance += _calculateDistance(points[i-1], points[i]);
    }
    
    // Adaptive filtering based on route length
    int skipInterval = totalDistance > 5000 ? 4 : 2; // Skip more points for longer routes
    
    for (int i = 1; i < points.length - 1; i++) {
      // Keep points at regular intervals or significant direction changes
      if (i % skipInterval == 0 || _isSignificantTurn(points, i)) {
        filtered.add(points[i]);
      }
    }
    
    filtered.add(points.last); // Always keep last point
    return filtered;
  }
  
  /// Calculate distance between two points in meters
  static double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters
    final lat1Rad = point1.latitude * (3.14159 / 180);
    final lat2Rad = point2.latitude * (3.14159 / 180);
    final deltaLat = (point2.latitude - point1.latitude) * (3.14159 / 180);
    final deltaLng = (point2.longitude - point1.longitude) * (3.14159 / 180);
    
    final a = (deltaLat / 2) * (deltaLat / 2) +
        (lat1Rad) * (lat2Rad) *
        (deltaLng / 2) * (deltaLng / 2);
    final c = 2 * (a < 1 ? a : 1); // Simplified for better performance
    
    return earthRadius * c;
  }
  
  /// Check if a point represents a significant turn
  static bool _isSignificantTurn(List<LatLng> points, int index) {
    if (index <= 0 || index >= points.length - 1) return false;
    
    final prev = points[index - 1];
    final current = points[index];
    final next = points[index + 1];
    
    // Calculate bearing change
    final bearing1 = _calculateBearing(prev, current);
    final bearing2 = _calculateBearing(current, next);
    final bearingChange = (bearing2 - bearing1).abs();
    
    // Consider it a significant turn if bearing changes by more than 30 degrees
    return bearingChange > 30 && bearingChange < 330;
  }
  
  /// Calculate bearing between two points
  static double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (3.14159 / 180);
    final lat2 = end.latitude * (3.14159 / 180);
    final deltaLng = (end.longitude - start.longitude) * (3.14159 / 180);
    
    final y = deltaLng * lat2;
    final x = lat1 - lat2;
    
    return (x + y) * (180 / 3.14159); // Simplified bearing calculation
  }
  
  /// Filter route points to reduce density while maintaining shape (legacy method)
  static List<LatLng> _filterRoutePoints(List<LatLng> points) {
    return _enhancedFilterRoutePoints(points); // Use enhanced version
  }
  
  /// Get route points between multiple waypoints
  static Future<List<LatLng>> getMultiWaypointRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return waypoints;
    
    List<LatLng> allRoutePoints = [];
    
    // Get route segments between consecutive waypoints
    for (int i = 0; i < waypoints.length - 1; i++) {
      final segmentPoints = await getRoutePoints(waypoints[i], waypoints[i + 1]);
      
      // Add segment points (skip first point of subsequent segments to avoid duplicates)
      if (i == 0) {
        allRoutePoints.addAll(segmentPoints);
      } else {
        allRoutePoints.addAll(segmentPoints.skip(1));
      }
      
      // Add small delay to avoid overwhelming the API
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return allRoutePoints;
  }
  
  /// Calculate approximate distance between two points (in kilometers)
  static double calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }
  
  /// Calculate total distance for a route with multiple points
  static double calculateTotalDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += calculateDistance(points[i], points[i + 1]);
    }
    
    return totalDistance;
  }
}