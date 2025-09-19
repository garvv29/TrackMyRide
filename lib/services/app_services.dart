import '../services/api_service.dart';
import '../services/api_config.dart';

class BusSchedule {
  final String id;
  final String routeId;
  final String busId;
  final String scheduleDate;
  final String departureTime;
  final String arrivalTime;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusSchedule({
    required this.id,
    required this.routeId,
    required this.busId,
    required this.scheduleDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    return BusSchedule(
      id: json['id'] ?? '',
      routeId: json['routeId'] ?? '',
      busId: json['busId'] ?? '',
      scheduleDate: json['scheduleDate'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      status: json['status'] ?? 'scheduled',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get timeRange => '$departureTime - $arrivalTime';
  bool get isRunning => status == 'running';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}

class Complaint {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  Complaint({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'general',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'medium',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
    };
  }

  bool get isOpen => status == 'open';
  bool get isResolved => status == 'resolved';
  String get statusText => status.toUpperCase();
  String get priorityText => priority.toUpperCase();
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class ScheduleService {
  static final ApiService _apiService = ApiService();

  // Get schedules by route
  static Future<List<BusSchedule>> getSchedulesByRoute(String routeId) async {
    try {
      final response = await _apiService.get(
        ApiConfig.schedules,
        queryParams: {'routeId': routeId},
      );
      final List<dynamic> schedulesJson = response['schedules'] ?? [];
      return schedulesJson.map((json) => BusSchedule.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load schedules: ${e.toString()}');
    }
  }

  // Get schedules by date
  static Future<List<BusSchedule>> getSchedulesByDate(String date) async {
    try {
      final response = await _apiService.get(
        ApiConfig.schedules,
        queryParams: {'date': date},
      );
      final List<dynamic> schedulesJson = response['schedules'] ?? [];
      return schedulesJson.map((json) => BusSchedule.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load schedules by date: ${e.toString()}');
    }
  }

  // Get schedules for today
  static Future<List<BusSchedule>> getTodaySchedules() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return getSchedulesByDate(today);
  }
}

class ComplaintService {
  static final ApiService _apiService = ApiService();

  // Submit complaint
  static Future<Complaint> submitComplaint({
    required String title,
    required String description,
    required String category,
    String priority = 'medium',
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.complaints,
        data: {
          'title': title,
          'description': description,
          'category': category,
          'priority': priority,
        },
      );
      return Complaint.fromJson(response['complaint']);
    } catch (e) {
      throw Exception('Failed to submit complaint: ${e.toString()}');
    }
  }

  // Get user complaints
  static Future<List<Complaint>> getUserComplaints() async {
    try {
      final response = await _apiService.get(ApiConfig.complaints);
      final List<dynamic> complaintsJson = response['complaints'] ?? [];
      return complaintsJson.map((json) => Complaint.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load complaints: ${e.toString()}');
    }
  }
}

class NotificationService {
  static final ApiService _apiService = ApiService();

  // Get user notifications
  static Future<List<AppNotification>> getUserNotifications() async {
    try {
      final response = await _apiService.get(ApiConfig.notifications);
      final List<dynamic> notificationsJson = response['notifications'] ?? [];
      return notificationsJson.map((json) => AppNotification.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load notifications: ${e.toString()}');
    }
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.put('${ApiConfig.notifications}/$notificationId/read');
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  // Mark all notifications as read
  static Future<void> markAllAsRead() async {
    try {
      await _apiService.put('${ApiConfig.notifications}/mark-all-read');
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }
}