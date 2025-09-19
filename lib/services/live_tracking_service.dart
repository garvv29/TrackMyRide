import 'dart:async';
import 'package:latlong2/latlong.dart';
import '../models/bus_tracking_models.dart';
import '../services/route_service.dart';

class LiveTrackingService {
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
      // For now, simulate live data - in real app this would come from GPS tracker
      final response = await _simulateBusData(busId);
      return response;
    } catch (e) {
      print('Error fetching bus location: $e');
      return null;
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
  
  /// Simulate stop timings (replace with real schedule data later)
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