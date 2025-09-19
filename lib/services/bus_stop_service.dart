import '../services/api_service.dart';
import '../services/api_config.dart';

class BusStop {
  final String id;
  final String stopName;
  final String stopCode;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final List<String> amenities;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusStop({
    required this.id,
    required this.stopName,
    required this.stopCode,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.amenities,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>? ?? {};
    
    // Handle timestamps that might be missing or in different formats
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is String) {
        try {
          return DateTime.parse(timestamp);
        } catch (e) {
          return DateTime.now();
        }
      }
      if (timestamp is Map && timestamp.containsKey('_seconds')) {
        // Firestore timestamp format
        final seconds = timestamp['_seconds'] as int;
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
      return DateTime.now();
    }
    
    return BusStop(
      id: json['id'] ?? '',
      stopName: json['stopName'] ?? '',
      stopCode: json['stopCode'] ?? '',
      latitude: (coordinates['latitude'] ?? 0.0).toDouble(),
      longitude: (coordinates['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stopName': stopName,
      'stopCode': stopCode,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'address': address,
      'city': city,
      'state': state,
      'amenities': amenities,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayName => '$stopName ($stopCode)';
  
  bool get hasAmenities => amenities.isNotEmpty;
  
  String get amenitiesText => amenities.join(', ');
}

class BusStopService {
  static final ApiService _apiService = ApiService();

  // Get all bus stops
  static Future<List<BusStop>> getAllBusStops() async {
    try {
      final response = await _apiService.get(ApiConfig.busStops);
      final List<dynamic> stopsJson = response['busStops'] ?? [];
      return stopsJson.map((json) => BusStop.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load bus stops: ${e.toString()}');
    }
  }

  // Get bus stop by ID
  static Future<BusStop> getBusStopById(String stopId) async {
    try {
      final response = await _apiService.get('${ApiConfig.busStops}/$stopId');
      return BusStop.fromJson(response['busStop']);
    } catch (e) {
      throw Exception('Failed to load bus stop: ${e.toString()}');
    }
  }

  // Search bus stops
  static Future<List<BusStop>> searchBusStops(String query) async {
    try {
      final response = await _apiService.get(
        ApiConfig.searchBusStops,
        queryParams: {'query': query},
      );
      final List<dynamic> stopsJson = response['busStops'] ?? [];
      return stopsJson.map((json) => BusStop.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search bus stops: ${e.toString()}');
    }
  }

  // Get nearby bus stops
  static Future<List<BusStop>> getNearbyBusStops({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConfig.nearbyStops,
        queryParams: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'radius': radiusKm.toString(),
        },
      );
      final List<dynamic> stopsJson = response['busStops'] ?? [];
      return stopsJson.map((json) => BusStop.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load nearby bus stops: ${e.toString()}');
    }
  }

  // Get bus stops by city
  static Future<List<BusStop>> getBusStopsByCity(String city) async {
    try {
      final response = await _apiService.get(
        ApiConfig.busStops,
        queryParams: {'city': city},
      );
      final List<dynamic> stopsJson = response['busStops'] ?? [];
      return stopsJson.map((json) => BusStop.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load bus stops by city: ${e.toString()}');
    }
  }

  // Get bus stops by route
  static Future<List<BusStop>> getBusStopsByRoute(String routeId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.routes}/$routeId/stops',
      );
      final List<dynamic> stopsJson = response['busStops'] ?? [];
      return stopsJson.map((json) => BusStop.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load route bus stops: ${e.toString()}');
    }
  }
}