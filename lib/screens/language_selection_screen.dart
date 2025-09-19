import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'theme_selection_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

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
              const Text(
                'Track My Ride',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your preferred language',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 60),
              
              // Language Options
              Expanded(
                child: ListView(
                  children: [
                    _buildLanguageOption(context, 'English', 'en'),
                    _buildLanguageOption(context, 'हिंदी', 'hi'),
                    _buildLanguageOption(context, 'ગુજરાતી', 'gu'),
                    _buildLanguageOption(context, 'मराठी', 'mr'),
                    _buildLanguageOption(context, 'தமிழ்', 'ta'),
                    _buildLanguageOption(context, 'తెలుగు', 'te'),
                    _buildLanguageOption(context, 'ಕನ್ನಡ', 'kn'),
                    _buildLanguageOption(context, 'മലയാളം', 'ml'),
                    _buildLanguageOption(context, 'বাংলা', 'bn'),
                    _buildLanguageOption(context, 'ਪੰਜਾਬੀ', 'pa'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageName,
    String languageCode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await context.read<AppProvider>().setLocale(Locale(languageCode));
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ThemeSelectionScreen(),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3748).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: Color(0xFF2D3748),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    languageName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Color(0xFF718096),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}