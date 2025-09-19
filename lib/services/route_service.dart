import '../services/api_service.dart';
import '../services/api_config.dart';

class BusRoute {
  final String id;
  final String routeName;
  final String routeNumber;
  final String operatorId;
  final String startLocation;
  final String endLocation;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final double totalDistance;
  final int estimatedDuration;
  final String routeType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusRoute({
    required this.id,
    required this.routeName,
    required this.routeNumber,
    required this.operatorId,
    required this.startLocation,
    required this.endLocation,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.totalDistance,
    required this.estimatedDuration,
    required this.routeType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    final startCoords = json['startCoordinates'] as Map<String, dynamic>? ?? {};
    final endCoords = json['endCoordinates'] as Map<String, dynamic>? ?? {};
    
    // Handle Firestore GeoPoint format with _latitude/_longitude
    double startLat = 0.0;
    double startLng = 0.0;
    double endLat = 0.0;
    double endLng = 0.0;
    
    // Parse start coordinates
    if (startCoords.containsKey('_latitude')) {
      startLat = (startCoords['_latitude'] ?? 0.0).toDouble();
      startLng = (startCoords['_longitude'] ?? 0.0).toDouble();
    } else {
      startLat = (startCoords['latitude'] ?? 0.0).toDouble();
      startLng = (startCoords['longitude'] ?? 0.0).toDouble();
    }
    
    // Parse end coordinates
    if (endCoords.containsKey('_latitude')) {
      endLat = (endCoords['_latitude'] ?? 0.0).toDouble();
      endLng = (endCoords['_longitude'] ?? 0.0).toDouble();
    } else {
      endLat = (endCoords['latitude'] ?? 0.0).toDouble();
      endLng = (endCoords['longitude'] ?? 0.0).toDouble();
    }
    
    return BusRoute(
      id: json['id'] ?? '',
      routeName: json['routeName'] ?? '',
      routeNumber: json['routeNumber'] ?? '',
      operatorId: json['operatorId'] ?? '',
      startLocation: json['startLocation'] ?? '',
      endLocation: json['endLocation'] ?? '',
      startLatitude: startLat,
      startLongitude: startLng,
      endLatitude: endLat,
      endLongitude: endLng,
      totalDistance: (json['totalDistance'] ?? 0.0).toDouble(),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      routeType: json['routeType']?.toString() ?? 'City Bus', // Handle any type and convert to string
      isActive: json['isActive'] ?? true,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  // Helper method to parse various DateTime formats
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    // Handle Firestore Timestamp format
    if (dateValue is Map<String, dynamic>) {
      final seconds = dateValue['_seconds'] ?? dateValue['seconds'];
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }
    
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeName': routeName,
      'routeNumber': routeNumber,
      'operatorId': operatorId,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'startCoordinates': {
        'latitude': startLatitude,
        'longitude': startLongitude,
      },
      'endCoordinates': {
        'latitude': endLatitude,
        'longitude': endLongitude,
      },
      'totalDistance': totalDistance,
      'estimatedDuration': estimatedDuration,
      'routeType': routeType,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayName => '$routeName ($routeNumber)';
  String get routeDirection => '$startLocation → $endLocation';
  String get durationText => '${estimatedDuration}min';
  String get distanceText => '${totalDistance.toStringAsFixed(1)}km';
}

class RouteService {
  static final ApiService _apiService = ApiService();

  // Get all routes
  static Future<List<BusRoute>> getAllRoutes() async {
    try {
      final response = await _apiService.get(ApiConfig.routes);
      final List<dynamic> routesJson = response['routes'] ?? [];
      return routesJson.map((json) => BusRoute.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load routes: ${e.toString()}');
    }
  }

  // Get route by ID
  static Future<BusRoute> getRouteById(String routeId) async {
    try {
      final response = await _apiService.get('${ApiConfig.routes}/$routeId');
      return BusRoute.fromJson(response['route']);
    } catch (e) {
      throw Exception('Failed to load route: ${e.toString()}');
    }
  }

  // Search routes between locations
  static Future<List<BusRoute>> searchRoutes({
    required String from,
    required String to,
  }) async {
    try {
      print('RouteService: Searching routes from "$from" to "$to"');
      final response = await _apiService.get(
        ApiConfig.searchRoutes,
        queryParams: {
          'from': from,
          'to': to,
        },
      );
      print('RouteService: API response: $response');
      final List<dynamic> routesJson = response['routes'] ?? [];
      print('RouteService: Found ${routesJson.length} routes in response');
      
      final routes = routesJson.map((json) {
        print('RouteService: Parsing route: $json');
        return BusRoute.fromJson(json);
      }).toList();
      
      print('RouteService: Successfully parsed ${routes.length} routes');
      return routes;
    } catch (e) {
      print('RouteService: Error searching routes: $e');
      throw Exception('Failed to search routes: ${e.toString()}');
    }
  }

  // Get routes by operator
  static Future<List<BusRoute>> getRoutesByOperator(String operatorId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.routes}/operator/$operatorId',
      );
      final List<dynamic> routesJson = response['routes'] ?? [];
      return routesJson.map((json) => BusRoute.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load operator routes: ${e.toString()}');
    }
  }

  // Get routes by city
  static Future<List<BusRoute>> getRoutesByCity(String city) async {
    try {
      final response = await _apiService.get(
        ApiConfig.routes,
        queryParams: {'city': city},
      );
      final List<dynamic> routesJson = response['routes'] ?? [];
      return routesJson.map((json) => BusRoute.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load city routes: ${e.toString()}');
    }
  }

  // Search routes by route number
  static Future<List<BusRoute>> searchByRouteNumber(String routeNumber) async {
    try {
      final response = await _apiService.get(
        ApiConfig.routes,
        queryParams: {'routeNumber': routeNumber},
      );
      final List<dynamic> routesJson = response['routes'] ?? [];
      return routesJson.map((json) => BusRoute.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search routes by number: ${e.toString()}');
    }
  }

  // Get detailed stops for a route
  Future<List<RouteStop>> getRouteStops(String routeId) async {
    try {
      print('RouteService: Getting stops for route ID: $routeId');
      final response = await _apiService.get('${ApiConfig.routes}/$routeId/stops');
      final List<dynamic> stopsJson = response['stops'] ?? [];
      return stopsJson.map((json) => RouteStop.fromJson(json)).toList();
    } catch (e) {
      print('RouteService: Error getting route stops: ${e.toString()}');
      throw Exception('Failed to load route stops: ${e.toString()}');
    }
  }
}

// Model class for route stops
class RouteStop {
  final String routeStopId;
  final int stopOrder;
  final bool busStopsHere;
  final String arrivalTime;
  final String departureTime;
  final StopDetails stopDetails;

  RouteStop({
    required this.routeStopId,
    required this.stopOrder,
    required this.busStopsHere,
    required this.arrivalTime,
    required this.departureTime,
    required this.stopDetails,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      routeStopId: json['routeStopId'] ?? '',
      stopOrder: json['stopOrder'] ?? 0,
      busStopsHere: json['busStopsHere'] ?? true,
      arrivalTime: json['arrivalTime'] ?? '',
      departureTime: json['departureTime'] ?? '',
      stopDetails: StopDetails.fromJson(json['stopDetails'] ?? {}),
    );
  }
}

class StopDetails {
  final String id;
  final String stopName;
  final String stopCode;
  final Map<String, dynamic> coordinates;
  final String address;
  final List<String> amenities;
  final bool isMinorStop;

  StopDetails({
    required this.id,
    required this.stopName,
    required this.stopCode,
    required this.coordinates,
    required this.address,
    required this.amenities,
    required this.isMinorStop,
  });

  factory StopDetails.fromJson(Map<String, dynamic> json) {
    return StopDetails(
      id: json['id'] ?? '',
      stopName: json['stopName'] ?? '',
      stopCode: json['stopCode'] ?? '',
      coordinates: json['coordinates'] ?? {},
      address: json['address'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      isMinorStop: json['isMinorStop'] ?? false,
    );
  }
}