import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RouteSearchHistory {
  static const String _routeHistoryKey = 'route_search_history';
  static const int _maxHistory = 10;

  // Get recent route searches (from-to searches)
  static Future<List<RouteSearchItem>> getRecentRouteSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_routeHistoryKey) ?? [];
    
    return historyJson
        .map((json) => RouteSearchItem.fromJson(jsonDecode(json)))
        .toList();
  }

  // Add a new route search
  static Future<void> addRouteSearch(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    List<RouteSearchItem> searches = await getRecentRouteSearches();
    
    // Remove if already exists (to move to top)
    searches.removeWhere((item) => 
        item.from.toLowerCase() == from.toLowerCase() && 
        item.to.toLowerCase() == to.toLowerCase());
    
    // Add to beginning
    searches.insert(0, RouteSearchItem(
      from: from,
      to: to,
      timestamp: DateTime.now(),
    ));
    
    // Keep only max items
    if (searches.length > _maxHistory) {
      searches = searches.take(_maxHistory).toList();
    }
    
    // Save to preferences
    final historyJson = searches
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    
    await prefs.setStringList(_routeHistoryKey, historyJson);
  }

  // Remove a specific route search
  static Future<void> removeRouteSearch(RouteSearchItem searchItem) async {
    final prefs = await SharedPreferences.getInstance();
    List<RouteSearchItem> searches = await getRecentRouteSearches();
    
    searches.removeWhere((item) => 
        item.from == searchItem.from && 
        item.to == searchItem.to &&
        item.timestamp == searchItem.timestamp);
    
    final historyJson = searches
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    
    await prefs.setStringList(_routeHistoryKey, historyJson);
  }

  // Clear all route search history
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_routeHistoryKey);
  }
}

class RouteSearchItem {
  final String from;
  final String to;
  final DateTime timestamp;

  RouteSearchItem({
    required this.from,
    required this.to,
    required this.timestamp,
  });

  factory RouteSearchItem.fromJson(Map<String, dynamic> json) {
    return RouteSearchItem(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get displayText {
    return '$from → $to';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
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