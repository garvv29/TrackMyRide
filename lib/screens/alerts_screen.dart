import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  List<Map<String, dynamic>> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to load alerts from backend
      final apiService = ApiService();
      final response = await apiService.get(ApiConfig.notifications);
      if (response['success'] == true) {
        setState(() {
          _alerts = List<Map<String, dynamic>>.from(response['notifications'] ?? []);
        });
      }
    } catch (e) {
      // If backend is not available or no alerts, show empty state
      print('Error loading alerts: $e');
      setState(() {
        _alerts = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Alert Settings
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Stay updated with bus alerts and notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Alerts List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _alerts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _alerts.length,
                        itemBuilder: (context, index) {
                          final alert = _alerts[index];
                          return _buildAlertCard(
                            alert['title'] ?? 'Alert',
                            alert['message'] ?? '',
                            _getIconForType(alert['type']),
                            _getColorForType(alert['type']),
                            alert['time'] ?? 'Just now',
                            alert['isRead'] ?? false,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No alerts at the moment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll be notified when there are important\nupdates about bus services',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _loadAlerts,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'route':
        return Icons.route;
      case 'service':
        return Icons.new_releases;
      case 'maintenance':
        return Icons.build;
      case 'fare':
        return Icons.currency_rupee;
      default:
        return Icons.info;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'warning':
        return Colors.orange;
      case 'route':
        return Colors.blue;
      case 'service':
        return Colors.green;
      case 'maintenance':
        return Colors.red;
      case 'fare':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAlertCard(
    String title,
    String message,
    IconData icon,
    Color color,
    String time,
    bool isRead,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRead
            ? BorderSide.none
            : BorderSide(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Mark as read and show detailed alert
        },
      ),
    );
  }
}