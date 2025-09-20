import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.settings ?? 'Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildThemeSettingCard(context),
          _buildLanguageSettingCard(context),
          const SizedBox(height: 20),
          
          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildNotificationCard(
            'Bus Alerts',
            'Get notified about service updates and delays',
            true,
            (value) {
              // TODO: Update notification settings
            },
          ),
          _buildNotificationCard(
            'Route Changes',
            'Receive alerts about route modifications',
            true,
            (value) {
              // TODO: Update notification settings
            },
          ),
          const SizedBox(height: 20),
          
          // Location Section
          _buildSectionHeader('Location Services'),
          _buildLocationCard(),
          const SizedBox(height: 20),
          
          // Bus Tracking Section
          _buildSectionHeader('Bus Tracking'),
          _buildTrackingCard(
            'Auto-refresh',
            'Automatically update bus locations',
            true,
            (value) {
              // TODO: Update tracking settings
            },
          ),
          const SizedBox(height: 20),
          
          // Data Section
          _buildSectionHeader('Data & Storage'),
          _buildDataCard(
            'Clear Cache',
            'Free up storage space',
            Icons.delete_outline,
            () {
              _showClearCacheDialog(context);
            },
          ),
          const SizedBox(height: 20),
          
          // About Section
          _buildSectionHeader('About'),
          _buildAboutCard(
            'App Version',
            '1.0.0',
            Icons.info_outline,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildThemeSettingCard(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Card(
          child: ListTile(
            leading: Icon(
              appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Theme'),
            subtitle: Text(appProvider.isDarkMode ? 'Dark Mode' : 'Light Mode'),
            trailing: Switch(
              value: appProvider.isDarkMode,
              onChanged: (value) {
                appProvider.toggleTheme();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSettingCard(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Card(
          child: ListTile(
            leading: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Language'),
            subtitle: Text(_getLanguageName(appProvider.currentLocale.languageCode)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.notifications,
          color: value ? Colors.blue : Colors.grey,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.location_on,
          color: Colors.green,
        ),
        title: const Text('Location Access'),
        subtitle: const Text('Allow app to access your location for better services'),
        trailing: Switch(
          value: true,
          onChanged: (value) {
            // TODO: Handle location permission
          },
        ),
      ),
    );
  }

  Widget _buildTrackingCard(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.my_location,
          color: value ? Colors.orange : Colors.grey,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDataCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.red,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAboutCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.purple,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: title == 'App Version' 
            ? null 
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'gu':
        return 'ગુજરાતી';
      case 'mr':
        return 'मराठी';
      case 'ta':
        return 'தமிழ்';
      case 'te':
        return 'తెలుగు';
      case 'pa':
        return 'ਪੰਜਾਬੀ';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, 'English', 'en'),
              _buildLanguageOption(context, 'हिंदी', 'hi'),
              _buildLanguageOption(context, 'ਪੰਜਾਬੀ', 'pa'),
              _buildLanguageOption(context, 'ગુજરાતી', 'gu'),
              _buildLanguageOption(context, 'मराठी', 'mr'),
              _buildLanguageOption(context, 'தமிழ்', 'ta'),
              _buildLanguageOption(context, 'తెలుగు', 'te'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isSelected = appProvider.currentLocale.languageCode == code;
        return ListTile(
          title: Text(
            name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          trailing: isSelected ? Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          ) : null,
          onTap: () async {
            try {
              await context.read<AppProvider>().setLocale(Locale(code));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Language changed to $name'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to change language: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data including recent searches and saved routes. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}