import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Real-time bus tracking data
class LiveBusData {
  final String busId;
  final String routeId;
  final LatLng currentLocation;
  final double speed; // km/h
  final String direction; // "forward" or "backward"
  final int currentStopIndex;
  final DateTime lastUpdate;
  final bool isOnline;
  final double batteryLevel;
  final int passengerCount;

  LiveBusData({
    required this.busId,
    required this.routeId,
    required this.currentLocation,
    required this.speed,
    required this.direction,
    required this.currentStopIndex,
    required this.lastUpdate,
    required this.isOnline,
    this.batteryLevel = 100.0,
    this.passengerCount = 0,
  });

  factory LiveBusData.fromJson(Map<String, dynamic> json) {
    return LiveBusData(
      busId: json['busId'] ?? '',
      routeId: json['routeId'] ?? '',
      currentLocation: LatLng(
        json['currentLocation']['latitude']?.toDouble() ?? 0.0,
        json['currentLocation']['longitude']?.toDouble() ?? 0.0,
      ),
      speed: json['speed']?.toDouble() ?? 0.0,
      direction: json['direction'] ?? 'forward',
      currentStopIndex: json['currentStopIndex'] ?? 0,
      lastUpdate: DateTime.parse(json['lastUpdate'] ?? DateTime.now().toIso8601String()),
      isOnline: json['isOnline'] ?? false,
      batteryLevel: json['batteryLevel']?.toDouble() ?? 100.0,
      passengerCount: json['passengerCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busId': busId,
      'routeId': routeId,
      'currentLocation': {
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      },
      'speed': speed,
      'direction': direction,
      'currentStopIndex': currentStopIndex,
      'lastUpdate': lastUpdate.toIso8601String(),
      'isOnline': isOnline,
      'batteryLevel': batteryLevel,
      'passengerCount': passengerCount,
    };
  }
}

/// Bus stop timing and ETA information
class StopTiming {
  final String stopId;
  final String stopName;
  final DateTime scheduledArrival;
  final DateTime? actualArrival;
  final DateTime estimatedArrival;
  final int delayMinutes;
  final bool isPassed;
  final bool isNext;
  final double distanceFromBus; // km

  StopTiming({
    required this.stopId,
    required this.stopName,
    required this.scheduledArrival,
    this.actualArrival,
    required this.estimatedArrival,
    required this.delayMinutes,
    required this.isPassed,
    required this.isNext,
    required this.distanceFromBus,
  });

  factory StopTiming.fromJson(Map<String, dynamic> json) {
    return StopTiming(
      stopId: json['stopId'] ?? '',
      stopName: json['stopName'] ?? '',
      scheduledArrival: DateTime.parse(json['scheduledArrival']),
      actualArrival: json['actualArrival'] != null 
          ? DateTime.parse(json['actualArrival'])
          : null,
      estimatedArrival: DateTime.parse(json['estimatedArrival']),
      delayMinutes: json['delayMinutes'] ?? 0,
      isPassed: json['isPassed'] ?? false,
      isNext: json['isNext'] ?? false,
      distanceFromBus: json['distanceFromBus']?.toDouble() ?? 0.0,
    );
  }

  String get statusText {
    if (isPassed) return 'Passed';
    if (isNext) return 'Next Stop';
    if (delayMinutes > 0) return '${delayMinutes}m late';
    if (delayMinutes < 0) return '${delayMinutes.abs()}m early';
    return 'On time';
  }

  Color get statusColor {
    if (isPassed) return Colors.grey;
    if (isNext) return Colors.green;
    if (delayMinutes > 5) return Colors.red;
    if (delayMinutes > 0) return Colors.orange;
    return Colors.blue;
  }
}

/// Route progress information
class RouteProgress {
  final double completedPercentage;
  final double totalDistance;
  final double completedDistance;
  final double remainingDistance;
  final Duration estimatedTimeToEnd;
  final Duration totalDelay;
  final int totalStops;
  final int completedStops;
  final int remainingStops;

  RouteProgress({
    required this.completedPercentage,
    required this.totalDistance,
    required this.completedDistance,
    required this.remainingDistance,
    required this.estimatedTimeToEnd,
    required this.totalDelay,
    required this.totalStops,
    required this.completedStops,
    required this.remainingStops,
  });

  factory RouteProgress.fromJson(Map<String, dynamic> json) {
    return RouteProgress(
      completedPercentage: json['completedPercentage']?.toDouble() ?? 0.0,
      totalDistance: json['totalDistance']?.toDouble() ?? 0.0,
      completedDistance: json['completedDistance']?.toDouble() ?? 0.0,
      remainingDistance: json['remainingDistance']?.toDouble() ?? 0.0,
      estimatedTimeToEnd: Duration(minutes: json['estimatedTimeToEnd'] ?? 0),
      totalDelay: Duration(minutes: json['totalDelay'] ?? 0),
      totalStops: json['totalStops'] ?? 0,
      completedStops: json['completedStops'] ?? 0,
      remainingStops: json['remainingStops'] ?? 0,
    );
  }

  String get progressText {
    return '${completedPercentage.toStringAsFixed(1)}% Complete';
  }

  String get distanceText {
    return '${completedDistance.toStringAsFixed(1)}/${totalDistance.toStringAsFixed(1)} km';
  }

  String get etaText {
    int totalMinutes = estimatedTimeToEnd.inMinutes;
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m remaining';
    } else {
      return '${minutes}m remaining';
    }
  }

  String get delayText {
    if (totalDelay.inMinutes == 0) return 'On time';
    if (totalDelay.inMinutes > 0) return '${totalDelay.inMinutes}m delayed';
    return '${totalDelay.inMinutes.abs()}m ahead';
  }
}