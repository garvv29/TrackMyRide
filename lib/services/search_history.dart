import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistory {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxSearchHistory = 10;

  // Get recent searches
  static Future<List<SearchItem>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searchHistoryJson = prefs.getStringList(_searchHistoryKey) ?? [];
    
    return searchHistoryJson
        .map((json) => SearchItem.fromJson(jsonDecode(json)))
        .toList();
  }

  // Add a new search
  static Future<void> addSearch(String query, String type) async {
    final prefs = await SharedPreferences.getInstance();
    List<SearchItem> searches = await getRecentSearches();
    
    // Remove if already exists (to move to top)
    searches.removeWhere((item) => 
        item.query.toLowerCase() == query.toLowerCase() && 
        item.type == type);
    
    // Add to beginning
    searches.insert(0, SearchItem(
      query: query,
      type: type,
      timestamp: DateTime.now(),
    ));
    
    // Keep only max items
    if (searches.length > _maxSearchHistory) {
      searches = searches.take(_maxSearchHistory).toList();
    }
    
    // Save to preferences
    final searchHistoryJson = searches
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    
    await prefs.setStringList(_searchHistoryKey, searchHistoryJson);
  }

  // Remove a specific search
  static Future<void> removeSearch(SearchItem searchItem) async {
    final prefs = await SharedPreferences.getInstance();
    List<SearchItem> searches = await getRecentSearches();
    
    searches.removeWhere((item) => 
        item.query == searchItem.query && 
        item.type == searchItem.type &&
        item.timestamp == searchItem.timestamp);
    
    final searchHistoryJson = searches
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    
    await prefs.setStringList(_searchHistoryKey, searchHistoryJson);
  }

  // Clear all search history
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }
}

class SearchItem {
  final String query;
  final String type; // 'route' or 'number'
  final DateTime timestamp;

  SearchItem({
    required this.query,
    required this.type,
    required this.timestamp,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      query: json['query'] ?? '',
      type: json['type'] ?? 'route',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get displayText {
    if (type == 'number') {
      return 'Bus $query';
    } else {
      return query;
    }
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