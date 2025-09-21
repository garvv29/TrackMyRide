import 'dart:math';

// SimpleBusStop interface implementation
class BusStop {
  final String? id;
  final String stopName;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final Map<String, double> coordinates;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields for app functionality
  final String? stopCode;
  final double? distance;
  final List<String>? busNumbers;
  final String? nextBusArrival;

  BusStop({
    this.id,
    required this.stopName,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    Map<String, double>? coordinates,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.stopCode,
    this.distance,
    this.busNumbers,
    this.nextBusArrival,
  }) : coordinates = coordinates ?? {'latitude': latitude, 'longitude': longitude};

  // Legacy constructor for backward compatibility
  BusStop.legacy({
    required String id,
    required String name,
    required double distance,
    required List<String> busNumbers,
    required String address,
    required String nextBusArrival,
  }) : this(
    id: id,
    stopName: name,
    city: '',
    state: '',
    latitude: 0.0,
    longitude: 0.0,
    coordinates: {'latitude': 0.0, 'longitude': 0.0},
    address: address,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    distance: distance,
    busNumbers: busNumbers,
    nextBusArrival: nextBusArrival,
  );

  // Legacy getter for backward compatibility
  String get name => stopName;

  // Convert from JSON (SimpleBusStop interface)
  factory BusStop.fromJson(Map<String, dynamic> json) {
    // Handle both direct latitude/longitude and coordinates object (including Firebase format)
    double lat = 0.0;
    double lng = 0.0;
    Map<String, double> coords = {'latitude': 0.0, 'longitude': 0.0};
    
    if (json['latitude'] != null && json['longitude'] != null) {
      lat = (json['latitude']).toDouble();
      lng = (json['longitude']).toDouble();
      coords = {'latitude': lat, 'longitude': lng};
    } else if (json['coordinates'] != null) {
      final coordsObj = json['coordinates'];
      // Handle Firebase GeoPoint format (_latitude, _longitude)
      if (coordsObj['_latitude'] != null && coordsObj['_longitude'] != null) {
        lat = (coordsObj['_latitude']).toDouble();
        lng = (coordsObj['_longitude']).toDouble();
      } else {
        lat = (coordsObj['latitude'] ?? 0.0).toDouble();
        lng = (coordsObj['longitude'] ?? 0.0).toDouble();
      }
      coords = {'latitude': lat, 'longitude': lng};
    }

    // Handle Firebase Timestamp format
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else if (timestamp is Map && timestamp.containsKey('_seconds')) {
        // Firebase Timestamp format
        int seconds = timestamp['_seconds'] ?? 0;
        int nanoseconds = timestamp['_nanoseconds'] ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + (nanoseconds ~/ 1000000));
      } else if (timestamp is DateTime) {
        return timestamp;
      }
      return DateTime.now();
    }
    
    return BusStop(
      id: json['id'] ?? json['_id'],
      stopName: json['stopName'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      latitude: lat,
      longitude: lng,
      coordinates: coords,
      address: json['address'],
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
      stopCode: json['stopCode'],
      distance: json['distance']?.toDouble(),
      busNumbers: json['busNumbers']?.cast<String>(),
      nextBusArrival: json['nextBusArrival'],
    );
  }

  // Convert from Firebase Firestore document (SimpleBusStop interface)
  factory BusStop.fromFirestore(Map<String, dynamic> data) {
    return BusStop(
      id: data['id'],
      stopName: data['stopName'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      latitude: (data['latitude'] ?? data['coordinates']?['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? data['coordinates']?['longitude'] ?? 0.0).toDouble(),
      address: data['address'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] is DateTime 
              ? data['createdAt'] 
              : DateTime.fromMillisecondsSinceEpoch(data['createdAt'].millisecondsSinceEpoch))
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] is DateTime 
              ? data['updatedAt'] 
              : DateTime.fromMillisecondsSinceEpoch(data['updatedAt'].millisecondsSinceEpoch))
          : DateTime.now(),
      distance: data['distance']?.toDouble(),
      busNumbers: data['busNumbers']?.cast<String>(),
      nextBusArrival: data['nextBusArrival'],
    );
  }

  // Convert to JSON (SimpleBusStop interface)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stopName': stopName,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'coordinates': coordinates,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (distance != null) 'distance': distance,
      if (busNumbers != null) 'busNumbers': busNumbers,
      if (nextBusArrival != null) 'nextBusArrival': nextBusArrival,
    };
  }

  // Calculate distance from current location (in kilometers)
  double distanceFromLocation(double userLat, double userLng) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(latitude - userLat);
    double dLng = _degreesToRadians(longitude - userLng);
    
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(userLat)) * cos(_degreesToRadians(latitude)) *
        (sin(dLng / 2) * sin(dLng / 2));
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}