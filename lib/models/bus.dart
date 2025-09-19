// Legacy Bus model - keeping for compatibility
class Bus {
  final String busNumber;
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String busType;
  final List<String> stops;
  final String frequency;

  Bus({
    required this.busNumber,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.busType,
    required this.stops,
    required this.frequency,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      busNumber: json['busNumber'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      duration: json['duration'] ?? '',
      busType: json['busType'] ?? '',
      stops: List<String>.from(json['stops'] ?? []),
      frequency: json['frequency'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busNumber': busNumber,
      'from': from,
      'to': to,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'busType': busType,
      'stops': stops,
      'frequency': frequency,
    };
  }
}

class BusStop {
  final String name;
  final double latitude;
  final double longitude;
  final String arrivalTime;
  final String departureTime;

  BusStop({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.arrivalTime,
    required this.departureTime,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      arrivalTime: json['arrivalTime'] ?? '',
      departureTime: json['departureTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'arrivalTime': arrivalTime,
      'departureTime': departureTime,
    };
  }
}