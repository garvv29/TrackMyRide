import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';
import 'main_screen.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // App Icon and Title
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D3748).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)?.chooseYourStyle ?? 'Choose Your Style',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)?.selectAppearance ?? 'Select the appearance that suits you best',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),
              
              // Theme Options
              Expanded(
                child: Column(
                  children: [
                    // Light Mode Option
                    _buildThemeOption(
                      context,
                      AppLocalizations.of(context)?.lightMode ?? 'Light Mode',
                      AppLocalizations.of(context)?.cleanBrightInterface ?? 'Clean and bright interface',
                      Icons.light_mode_rounded,
                      false,
                      const Color(0xFFFFFFFF),
                      const Color(0xFF2D3748),
                      const Color(0xFFF7FAFC),
                    ),
                    const SizedBox(height: 24),
                    
                    // Dark Mode Option
                    _buildThemeOption(
                      context,
                      AppLocalizations.of(context)?.darkMode ?? 'Dark Mode',
                      AppLocalizations.of(context)?.easyOnEyes ?? 'Easy on your eyes',
                      Icons.dark_mode_rounded,
                      true,
                      const Color(0xFF171923),
                      const Color(0xFF38B2AC),
                      const Color(0xFF1A202C),
                    ),
                    
                    const Spacer(),
                    
                    // Skip Button
                    TextButton(
                      onPressed: () {
                        _completeSetup(context, false);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF718096),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.skipForNow ?? 'Skip for now',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
    Color backgroundColor,
    Color iconColor,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _completeSetup(context, isDark);
          },
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? const Color(0xFF718096) : const Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _completeSetup(BuildContext context, bool isDark) {
    final appProvider = context.read<AppProvider>();
    appProvider.setTheme(isDark);
    appProvider.completeFirstTimeSetup();
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }
}