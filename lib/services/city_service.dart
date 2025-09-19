import '../services/api_service.dart';
import '../services/api_config.dart';

class City {
  final String id;
  final String cityName;
  final String state;
  final String country;
  final double latitude;
  final double longitude;
  final bool isActive;
  final List<String> majorLandmarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  City({
    required this.id,
    required this.cityName,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.majorLandmarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing city JSON: $json');
      
      final coordinates = json['coordinates'] as Map<String, dynamic>? ?? {};
      print('📍 Coordinates: $coordinates');
      
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
      
      final city = City(
        id: json['id']?.toString() ?? '',
        cityName: json['cityName']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        country: json['country']?.toString() ?? '',
        latitude: (coordinates['latitude'] ?? 0.0).toDouble(),
        longitude: (coordinates['longitude'] ?? 0.0).toDouble(),
        isActive: json['isActive'] ?? true,
        majorLandmarks: List<String>.from(json['majorLandmarks'] ?? []),
        createdAt: parseTimestamp(json['createdAt']),
        updatedAt: parseTimestamp(json['updatedAt']),
      );
      
      print('✅ Successfully parsed city: ${city.cityName}');
      return city;
    } catch (e, stackTrace) {
      print('❌ Error parsing city JSON: $e');
      print('📋 Stack trace: $stackTrace');
      print('📄 JSON data: $json');
      throw Exception('Failed to parse city: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityName': cityName,
      'state': state,
      'country': country,
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'isActive': isActive,
      'majorLandmarks': majorLandmarks,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CityService {
  static final ApiService _apiService = ApiService();

  // Get all cities
  static Future<List<City>> getAllCities() async {
    try {
      final response = await _apiService.get(ApiConfig.cities);
      final List<dynamic> citiesJson = response['cities'] ?? [];
      return citiesJson.map((json) => City.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load cities: ${e.toString()}');
    }
  }

  // Get city by ID
  static Future<City> getCityById(String cityId) async {
    try {
      final response = await _apiService.get('${ApiConfig.cities}/$cityId');
      return City.fromJson(response['city']);
    } catch (e) {
      throw Exception('Failed to load city: ${e.toString()}');
    }
  }

  // Search cities by name
  static Future<List<City>> searchCities(String query) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.cities}/search',
        queryParams: {'query': query},
      );
      final List<dynamic> citiesJson = response['cities'] ?? [];
      return citiesJson.map((json) => City.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search cities: ${e.toString()}');
    }
  }

  // Get cities by state
  static Future<List<City>> getCitiesByState(String state) async {
    try {
      final response = await _apiService.get(
        ApiConfig.cities,
        queryParams: {'state': state},
      );
      final List<dynamic> citiesJson = response['cities'] ?? [];
      return citiesJson.map((json) => City.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load cities by state: ${e.toString()}');
    }
  }
}