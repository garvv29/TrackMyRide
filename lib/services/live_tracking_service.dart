import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/bus_tracking_models.dart';
import '../services/route_service.dart';

class LiveTrackingService {
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000'; // iOS simulator
  
  static const Duration _updateInterval = Duration(seconds: 10);
  
  Timer? _trackingTimer;
  StreamController<LiveBusData>? _busDataController;
  StreamController<List<StopTiming>>? _stopTimingsController;
  StreamController<RouteProgress>? _progressController;
  
  // Streams for real-time updates
  Stream<LiveBusData>? get busDataStream => _busDataController?.stream;
  Stream<List<StopTiming>>? get stopTimingsStream => _stopTimingsController?.stream;
  Stream<RouteProgress>? get progressStream => _progressController?.stream;
  
  /// Start live tracking for a specific bus route
  Future<void> startTracking(String routeId, String busId) async {
    print('Starting live tracking for bus $busId on route $routeId');
    
    // Initialize stream controllers
    _busDataController = StreamController<LiveBusData>.broadcast();
    _stopTimingsController = StreamController<List<StopTiming>>.broadcast();
    _progressController = StreamController<RouteProgress>.broadcast();
    
    // Start periodic updates
    _trackingTimer = Timer.periodic(_updateInterval, (timer) {
      _fetchLiveData(routeId, busId);
    });
    
    // Initial fetch
    _fetchLiveData(routeId, busId);
  }
  
  /// Stop live tracking
  void stopTracking() {
    print('Stopping live tracking');
    
    _trackingTimer?.cancel();
    _trackingTimer = null;
    
    _busDataController?.close();
    _stopTimingsController?.close();
    _progressController?.close();
    
    _busDataController = null;
    _stopTimingsController = null;
    _progressController = null;
  }
  
  /// Fetch live data from backend
  Future<void> _fetchLiveData(String routeId, String busId) async {
    try {
      // Fetch live bus data
      final busData = await _fetchBusLocation(busId);
      if (busData != null) {
        _busDataController?.add(busData);
      }
      
      // Fetch stop timings
      final stopTimings = await _fetchStopTimings(routeId, busId);
      if (stopTimings.isNotEmpty) {
        _stopTimingsController?.add(stopTimings);
      }
      
      // Calculate and send progress
      if (busData != null && stopTimings.isNotEmpty) {
        final progress = await _calculateProgress(routeId, busData, stopTimings);
        if (progress != null) {
          _progressController?.add(progress);
        }
      }
    } catch (e) {
      print('Error fetching live data: $e');
    }
  }
  
  /// Fetch current bus location and status
  Future<LiveBusData?> _fetchBusLocation(String busId) async {
    try {
      // Try to get real live data from backend API
      final response = await http.get(
        Uri.parse('$baseUrl/api/location/live/$busId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final locationData = data['data'];
          
          // Convert backend data to LiveBusData model
          return LiveBusData(
            busId: locationData['busId'] ?? busId,
            routeId: locationData['routeId'] ?? 'route_raipur_004',
            currentLocation: LatLng(
              locationData['latitude']?.toDouble() ?? 21.2497,
              locationData['longitude']?.toDouble() ?? 81.6947,
            ),
            speed: locationData['speed']?.toDouble() ?? 0.0,
            direction: 'forward',
            currentStopIndex: _calculateStopIndex(LatLng(
              locationData['latitude']?.toDouble() ?? 21.2497,
              locationData['longitude']?.toDouble() ?? 81.6947,
            )),
            lastUpdate: DateTime.tryParse(locationData['timestamp'] ?? '') ?? DateTime.now(),
            isOnline: locationData['isActive'] ?? false,
            batteryLevel: 85.0,
            passengerCount: 15 + (DateTime.now().second % 25),
          );
        }
      } else {
        print('❌ API returned status: ${response.statusCode}');
      }
      
      // Fallback to simulation if API fails
      print('📍 Using simulated data for bus $busId');
      return await _simulateBusData(busId);
    } catch (e) {
      print('❌ Error fetching bus location: $e, using simulation');
      // Fallback to simulation
      return await _simulateBusData(busId);
    }
  }
  
  /// Fetch stop timings and ETAs
  Future<List<StopTiming>> _fetchStopTimings(String routeId, String busId) async {
    try {
      // This would normally call backend API
      // For now, simulate timing data based on current time
      return await _simulateStopTimings(routeId);
    } catch (e) {
      print('Error fetching stop timings: $e');
      return [];
    }
  }
  
  /// Calculate route progress
  Future<RouteProgress?> _calculateProgress(String routeId, LiveBusData busData, List<StopTiming> stopTimings) async {
    try {
      // Get route details for calculations
      final route = await RouteService.getRouteById(routeId);
      
      // Calculate progress based on current stop and distance
      final totalStops = stopTimings.length;
      final completedStops = stopTimings.where((s) => s.isPassed).length;
      final completedPercentage = totalStops > 0 ? (completedStops / totalStops) * 100 : 0.0;
      
      // Calculate distances (simplified)
      final totalDistance = route.totalDistance;
      final completedDistance = totalDistance * (completedPercentage / 100);
      final remainingDistance = totalDistance - completedDistance;
      
      // Calculate remaining time based on current speed
      final avgSpeed = busData.speed > 0 ? busData.speed : 25.0; // Default 25 km/h
      final remainingTimeHours = remainingDistance / avgSpeed;
      final remainingTimeMinutes = (remainingTimeHours * 60).round();
      
      // Calculate total delay
      final delayedStops = stopTimings.where((s) => s.delayMinutes > 0);
      final totalDelayMinutes = delayedStops.fold(0, (sum, stop) => sum + stop.delayMinutes);
      
      return RouteProgress(
        completedPercentage: completedPercentage,
        totalDistance: totalDistance,
        completedDistance: completedDistance,
        remainingDistance: remainingDistance,
        estimatedTimeToEnd: Duration(minutes: remainingTimeMinutes),
        totalDelay: Duration(minutes: totalDelayMinutes),
        totalStops: totalStops,
        completedStops: completedStops,
        remainingStops: totalStops - completedStops,
      );
    } catch (e) {
      print('Error calculating progress: $e');
      return null;
    }
  }
  
  /// Simulate live bus data (replace with real GPS data later)
  Future<LiveBusData> _simulateBusData(String busId) async {
    // Simulate bus moving along Railway Station to Magneto Mall route
    final currentTime = DateTime.now();
    final routeStartTime = DateTime(currentTime.year, currentTime.month, currentTime.day, 9, 0); // 9 AM start
    final minutesSinceStart = currentTime.difference(routeStartTime).inMinutes;
    
    // Simulate bus position based on time (using REAL Google Maps coordinates)
    final railwayStation = LatLng(21.2497, 81.6947); // Real Railway Station
    final magnetoMall = LatLng(21.2144, 81.6273);    // Real Magneto Mall
    
    // Move bus along the route (simplified linear interpolation)
    final progress = (minutesSinceStart % 32) / 32.0; // 32 min route cycle (realistic time)
    final currentLat = railwayStation.latitude + (magnetoMall.latitude - railwayStation.latitude) * progress;
    final currentLng = railwayStation.longitude + (magnetoMall.longitude - railwayStation.longitude) * progress;
    
    return LiveBusData(
      busId: busId,
      routeId: 'route_raipur_004',
      currentLocation: LatLng(currentLat, currentLng),
      speed: 20.0 + (DateTime.now().millisecond % 20), // 20-40 km/h
      direction: 'forward',
      currentStopIndex: (progress * 6).floor(), // 6 stops total (correct count)
      lastUpdate: DateTime.now(),
      isOnline: true,
      batteryLevel: 85.0,
      passengerCount: 15 + (DateTime.now().second % 25), // 15-40 passengers
    );
  }
  
  /// Calculate current stop index based on bus location
  int _calculateStopIndex(LatLng busLocation) {
    try {
      // Define Route 004 stops with real coordinates
      final List<LatLng> stops = [
        LatLng(21.2497, 81.6947), // Railway Station
        LatLng(21.2463, 81.6892), // Ghadi Chowk
        LatLng(21.2398, 81.6821), // Marine Drive
        LatLng(21.2287, 81.6654), // Telibandha
        LatLng(21.2201, 81.6432), // VIP Road Chowk
        LatLng(21.2144, 81.6273), // Magneto Mall
      ];
      
      // Find closest stop to current bus location
      double minDistance = double.infinity;
      int closestStopIndex = 0;
      
      for (int i = 0; i < stops.length; i++) {
        final distance = _calculateDistance(busLocation, stops[i]);
        if (distance < minDistance) {
          minDistance = distance;
          closestStopIndex = i;
        }
      }
      
      return closestStopIndex;
    } catch (e) {
      print('❌ Error calculating stop index: $e');
      return 0;
    }
  }
  
  /// Calculate distance between two points in kilometers
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // km
    final lat1Rad = point1.latitude * (3.14159 / 180);
    final lat2Rad = point2.latitude * (3.14159 / 180);
    final deltaLat = (point2.latitude - point1.latitude) * (3.14159 / 180);
    final deltaLng = (point2.longitude - point1.longitude) * (3.14159 / 180);
    
    final a = (deltaLat / 2) * (deltaLat / 2) +
        lat1Rad * lat2Rad *
        (deltaLng / 2) * (deltaLng / 2);
    final c = 2 * (a < 1 ? a : 1);
    
    return earthRadius * c;
  }
  
  /// Fetch all Route 004 live buses
  static Future<List<LiveBusData>> getRoute004LiveBuses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/location/route004/live'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> locationList = data['data'] ?? [];
          
          List<LiveBusData> busLocations = locationList.map((item) {
            return LiveBusData(
              busId: item['busId'] ?? '',
              routeId: item['routeId'] ?? 'route_raipur_004',
              currentLocation: LatLng(
                item['latitude']?.toDouble() ?? 21.2497,
                item['longitude']?.toDouble() ?? 81.6947,
              ),
              speed: item['speed']?.toDouble() ?? 0.0,
              direction: 'forward',
              currentStopIndex: 0,
              lastUpdate: DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
              isOnline: item['isActive'] ?? false,
              batteryLevel: 85.0,
              passengerCount: 15,
            );
          }).toList();
          
          print('📍 Received ${busLocations.length} Route 004 buses');
          return busLocations;
        }
      }
      
      return [];
    } catch (e) {
      print('❌ Error fetching Route 004 buses: $e');
      return [];
    }
  }
  Future<List<StopTiming>> _simulateStopTimings(String routeId) async {
    final now = DateTime.now();
    final baseTime = DateTime(now.year, now.month, now.day, 9, 0); // 9 AM start
    
    // Real Raipur route stops with updated timings and delays
    final stops = [
      {'name': 'Raipur Railway Station', 'scheduled': 0, 'delay': 0},
      {'name': 'Ghadi Chowk', 'scheduled': 8, 'delay': 2},
      {'name': 'Marine Drive', 'scheduled': 16, 'delay': 1},
      {'name': 'Telibandha', 'scheduled': 23, 'delay': 3},
      {'name': 'VIP Road Chowk', 'scheduled': 29, 'delay': 1},
      {'name': 'Magneto Mall', 'scheduled': 35, 'delay': 2},
    ];
    
    final currentMinute = now.difference(baseTime).inMinutes;
    
    return stops.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;
      final scheduledTime = baseTime.add(Duration(minutes: stop['scheduled'] as int));
      final delayMinutes = stop['delay'] as int;
      final estimatedTime = scheduledTime.add(Duration(minutes: delayMinutes));
      final isPassed = currentMinute > (stop['scheduled'] as int);
      final isNext = !isPassed && (index == 0 || currentMinute > (stops[index-1]['scheduled'] as int));
      
      return StopTiming(
        stopId: 'stop_${index + 1}',
        stopName: stop['name'] as String,
        scheduledArrival: scheduledTime,
        actualArrival: isPassed ? scheduledTime.add(Duration(minutes: delayMinutes)) : null,
        estimatedArrival: estimatedTime,
        delayMinutes: delayMinutes,
        isPassed: isPassed,
        isNext: isNext,
        distanceFromBus: isPassed ? 0.0 : ((stop['scheduled'] as int) - currentMinute) * 0.5, // Rough distance
      );
    }).toList();
  }
  
  /// Check if tracking is currently active
  bool get isTracking => _trackingTimer != null && _trackingTimer!.isActive;
  
  /// Get bus location once (without streaming)
  static Future<LiveBusData?> getBusLocationOnce(String busId) async {
    final service = LiveTrackingService();
    return await service._simulateBusData(busId);
  }
  
  /// Dispose resources
  void dispose() {
    stopTracking();
  }
}