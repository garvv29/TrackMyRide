import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/bus_stop.dart';
import 'api_config.dart';

class BusStopsService {

  /// Get all bus stops from backend API
  static Future<List<BusStop>> getAllBusStops() async {
    try {
      print('🔍 Fetching all bus stops from backend API...');
      
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.busStops)),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> stopsJson = data['data'] ?? data['busStops'] ?? data ?? [];
        
        List<BusStop> stops = stopsJson.map((stopJson) => BusStop.fromJson(stopJson)).toList();
        print('✅ Found ${stops.length} bus stops from backend');
        return stops;
      } else {
        throw Exception('Failed to fetch bus stops: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching bus stops from backend: $e');
      throw Exception('Failed to fetch bus stops: $e');
    }
  }

  /// Get nearby bus stops based on user location
  static Future<List<BusStop>> getNearbyBusStops({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      print('🔍 Fetching nearby bus stops within ${radiusKm}km of ($latitude, $longitude)');
      
      // Get all bus stops first (we'll filter by distance)
      List<BusStop> allStops = await getAllBusStops();
      
      // Filter stops within radius and calculate distances
      List<BusStop> nearbyStops = [];
      
      for (BusStop stop in allStops) {
        double distance = stop.distanceFromLocation(latitude, longitude);
        
        if (distance <= radiusKm) {
          nearbyStops.add(BusStop(
            id: stop.id,
            stopName: stop.stopName,
            city: stop.city,
            state: stop.state,
            latitude: stop.latitude,
            longitude: stop.longitude,
            coordinates: stop.coordinates,
            address: stop.address,
            createdAt: stop.createdAt,
            updatedAt: stop.updatedAt,
            stopCode: stop.stopCode,
            distance: distance,
          ));
        }
      }
      
      // Sort by distance
      nearbyStops.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
      
      print('✅ Found ${nearbyStops.length} nearby bus stops');
      return nearbyStops;
    } catch (e) {
      print('❌ Error fetching nearby bus stops: $e');
      return [];
    }
  }

  /// Get bus stops by city from backend API
  static Future<List<BusStop>> getBusStopsByCity(String city) async {
    try {
      print('🔍 Fetching bus stops for city: $city from backend');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.busStops)}?city=${Uri.encodeComponent(city)}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> stopsJson = data['data'] ?? data ?? [];
        
        List<BusStop> stops = stopsJson.map((stopJson) => BusStop.fromJson(stopJson)).toList();
        print('✅ Found ${stops.length} bus stops in $city from backend');
        return stops;
      } else {
        throw Exception('Failed to fetch bus stops for city: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching bus stops for city from backend: $e');
      throw Exception('Failed to fetch bus stops for city: $e');
    }
  }

  /// Get current user location
  static Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Location services disabled, using fallback location (Raipur)');
        // Return Raipur coordinates as fallback
        return Position(
          latitude: 21.2514,
          longitude: 81.6296,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      }

      // Check location permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Location permissions denied, using fallback location (Raipur)');
          // Return Raipur coordinates as fallback
          return Position(
            latitude: 21.2514,
            longitude: 81.6296,
            timestamp: DateTime.now(),
            accuracy: 100.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Location permissions permanently denied, using fallback location (Raipur)');
        // Return Raipur coordinates as fallback
        return Position(
          latitude: 21.2514,
          longitude: 81.6296,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      }

      // Get current position
      print('📍 Getting GPS location...');
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('❌ Error getting location: $e, using fallback location (Raipur)');
      // Return Raipur coordinates as fallback
      return Position(
        latitude: 21.2514,
        longitude: 81.6296,
        timestamp: DateTime.now(),
        accuracy: 100.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    }
  }

  /// Get user's city from coordinates (simplified version)
  static Future<String> getCityFromCoordinates(double lat, double lng) async {
    try {
      // For now, return a default city
      // TODO: Implement reverse geocoding when geocoding package is added
      return 'Unknown';
    } catch (e) {
      print('❌ Error getting city from coordinates: $e');
      return 'Unknown';
    }
  }
}