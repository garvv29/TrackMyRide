import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/app_provider.dart';
import 'screens/language_selection_screen.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'services/api_service.dart';

void main() {
  // Initialize API service
  ApiService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'Track My Ride',
            debugShowCheckedModeBanner: false,
            theme: appProvider.themeData,
            locale: appProvider.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('hi'), // Hindi
              Locale('gu'), // Gujarati
              Locale('mr'), // Marathi
              Locale('ta'), // Tamil
              Locale('te'), // Telugu
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/home': (context) => appProvider.isFirstTime 
                  ? const LanguageSelectionScreen()
                  : const MainScreen(),
            },
          );
        },
      ),
    );
  }
}
