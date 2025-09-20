import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../screens/saved_screen.dart';
import '../l10n/app_localizations.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Track My Ride',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Your travel companion',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 16),
                _buildDrawerItem(
                  context,
                  icon: Icons.bookmark,
                  title: AppLocalizations.of(context)?.saved ?? 'Saved',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: AppLocalizations.of(context)?.settings ?? 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: AppLocalizations.of(context)?.aboutUs ?? 'About Us',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: AppLocalizations.of(context)?.helpSupport ?? 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'About Track My Ride',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Track My Ride is your comprehensive transportation tracking application for finding the best routes across cities and between different locations. '
          'We help you plan your journey with real-time information and user-friendly features for buses, trains, and other public transport.\n\n'
          'Version: 1.0.0\n'
          'Developed with ❤️ for better public transportation',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need help? Here are some ways to get support:',
              style: TextStyle(
                color: Color(0xFF2D3748),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildHelpItem(Icons.email, 'Email: support@trackmyride.com'),
            const SizedBox(height: 8),
            _buildHelpItem(Icons.phone, 'Phone: +91 12345 67890'),
            const SizedBox(height: 8),
            _buildHelpItem(Icons.schedule, 'Hours: Mon-Fri 9AM-6PM'),
            const SizedBox(height: 16),
            Text(
              'Common Issues:\n'
              '• Bus not showing? Try refreshing the search\n'
              '• Wrong route? Report it through complaints\n'
              '• App issues? Restart the application',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String text) {
    return Builder(
      builder: (context) => Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}