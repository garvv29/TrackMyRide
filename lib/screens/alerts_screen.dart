import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Alert Settings
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                  value: true,
                  onChanged: (value) {
                    // TODO: Toggle notifications
                  },
                ),
              ],
            ),
          ),
          
          // Alerts List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAlertCard(
                  'Service Update',
                  'Bus 101 service will be delayed by 10 minutes due to traffic congestion on Main Street.',
                  Icons.warning,
                  Colors.orange,
                  '2 mins ago',
                  false,
                ),
                _buildAlertCard(
                  'Route Change',
                  'Bus 205 route has been temporarily modified. New stops added: Tech Park East, Innovation Center.',
                  Icons.route,
                  Colors.blue,
                  '15 mins ago',
                  false,
                ),
                _buildAlertCard(
                  'New Service',
                  'Introducing Bus 301 - Express service from Central Station to Airport. Starting tomorrow.',
                  Icons.new_releases,
                  Colors.green,
                  '1 hour ago',
                  true,
                ),
                _buildAlertCard(
                  'Maintenance Notice',
                  'Bus 150 will be out of service on Sunday for scheduled maintenance. Alternative routes available.',
                  Icons.build,
                  Colors.red,
                  '2 hours ago',
                  true,
                ),
                _buildAlertCard(
                  'Fare Update',
                  'Bus fare for AC services has been revised. New fare structure effective from next month.',
                  Icons.currency_rupee,
                  Colors.purple,
                  '1 day ago',
                  true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                color: color.withOpacity(0.3),
                width: 1,
              ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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