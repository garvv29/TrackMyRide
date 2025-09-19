import '../services/api_service.dart';
import '../services/api_config.dart';

class Bus {
  final String id;
  final String busNumber;
  final String vehicleNumber;
  final String busModel;
  final int capacity;
  final String operatorId;
  final String status;
  final List<String> amenities;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bus({
    required this.id,
    required this.busNumber,
    required this.vehicleNumber,
    required this.busModel,
    required this.capacity,
    required this.operatorId,
    required this.status,
    required this.amenities,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'] ?? '',
      busNumber: json['busNumber'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      busModel: json['busModel'] ?? '',
      capacity: json['capacity'] ?? 0,
      operatorId: json['operatorId'] ?? '',
      status: json['status'] ?? 'inactive',
      amenities: List<String>.from(json['amenities'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busNumber': busNumber,
      'vehicleNumber': vehicleNumber,
      'busModel': busModel,
      'capacity': capacity,
      'operatorId': operatorId,
      'status': status,
      'amenities': amenities,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayName => 'Bus $busNumber ($vehicleNumber)';
  String get capacityText => '$capacity seats';
  bool get hasAmenities => amenities.isNotEmpty;
  String get amenitiesText => amenities.join(', ');
  bool get isRunning => status == 'active' || status == 'running';
}

class BusLocation {
  final String busId;
  final double latitude;
  final double longitude;
  final double speed;
  final String direction;
  final DateTime timestamp;
  final bool isLive;

  BusLocation({
    required this.busId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.direction,
    required this.timestamp,
    required this.isLive,
  });

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    return BusLocation(
      busId: json['busId'] ?? '',
      latitude: (location['latitude'] ?? 0.0).toDouble(),
      longitude: (location['longitude'] ?? 0.0).toDouble(),
      speed: (json['speed'] ?? 0.0).toDouble(),
      direction: json['direction'] ?? 'N',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isLive: json['isLive'] ?? false,
    );
  }
}

class BusService {
  static final ApiService _apiService = ApiService();

  // Get all buses
  static Future<List<Bus>> getAllBuses() async {
    try {
      final response = await _apiService.get(ApiConfig.buses);
      final List<dynamic> busesJson = response['buses'] ?? [];
      return busesJson.map((json) => Bus.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load buses: ${e.toString()}');
    }
  }

  // Get bus by ID
  static Future<Bus> getBusById(String busId) async {
    try {
      final response = await _apiService.get('${ApiConfig.buses}/$busId');
      return Bus.fromJson(response['bus']);
    } catch (e) {
      throw Exception('Failed to load bus: ${e.toString()}');
    }
  }

  // Search buses
  static Future<List<Bus>> searchBuses(String query) async {
    try {
      final response = await _apiService.get(
        ApiConfig.searchBuses,
        queryParams: {'query': query},
      );
      final List<dynamic> busesJson = response['buses'] ?? [];
      return busesJson.map((json) => Bus.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search buses: ${e.toString()}');
    }
  }

  // Get buses by operator
  static Future<List<Bus>> getBusesByOperator(String operatorId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.buses}/operator/$operatorId',
      );
      final List<dynamic> busesJson = response['buses'] ?? [];
      return busesJson.map((json) => Bus.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load operator buses: ${e.toString()}');
    }
  }

  // Get live bus location
  static Future<BusLocation?> getBusLocation(String busId) async {
    try {
      final response = await _apiService.get('${ApiConfig.buses}/$busId/location');
      if (response['location'] != null) {
        return BusLocation.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get bus location: ${e.toString()}');
    }
  }

  // Get active buses in area
  static Future<List<BusLocation>> getActiveBusesInArea({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConfig.activeBuses,
        queryParams: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'radius': radiusKm.toString(),
        },
      );
      final List<dynamic> locationsJson = response['buses'] ?? [];
      return locationsJson.map((json) => BusLocation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get active buses: ${e.toString()}');
    }
  }

  // Get buses by route
  static Future<List<Bus>> getBusesByRoute(String routeId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.routes}/$routeId/buses',
      );
      final List<dynamic> busesJson = response['buses'] ?? [];
      return busesJson.map((json) => Bus.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load route buses: ${e.toString()}');
    }
  }

  // Get bus by vehicle number
  static Future<Bus?> getBusByVehicleNumber(String vehicleNumber) async {
    try {
      final response = await _apiService.get(
        ApiConfig.searchBuses,
        queryParams: {'vehicleNumber': vehicleNumber},
      );
      final List<dynamic> busesJson = response['buses'] ?? [];
      if (busesJson.isNotEmpty) {
        return Bus.fromJson(busesJson.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to find bus by vehicle number: ${e.toString()}');
    }
  }
}