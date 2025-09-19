class ApiConfig {
  // Base URLs for different scenarios:
  // - Android Emulator: Use 10.0.2.2:3000
  // - Physical Device: Use your PC's IP (192.168.29.163:3000)
  // - Web/Desktop: Use localhost:3000
  
  // Current config for Android device
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String healthUrl = 'http://192.168.29.163:3000/health';
  
  // Alternative URLs (change based on your setup):
  // For Emulator: 'http://10.0.2.2:3000/api'
  // For Localhost: 'http://localhost:3000/api'
  
  // API Endpoints
  static const String cities = '/cities';
  static const String busStops = '/bus-stops';
  static const String routes = '/routes';
  static const String buses = '/buses';
  static const String schedules = '/schedules';
  static const String complaints = '/complaints';
  static const String notifications = '/notifications';
  static const String auth = '/auth';
  static const String location = '/location';
  
  // Search endpoints
  static const String searchRoutes = '/routes/search';
  static const String searchBusStops = '/bus-stops/search';
  static const String searchBuses = '/buses/search';
  
  // Location endpoints
  static const String nearbyStops = '/bus-stops/nearby';
  static const String busLocation = '/location/bus';
  static const String activeBuses = '/location/active-buses';
  
  // Timeout settings - shorter to prevent ANR
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Request headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Get full URL
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}