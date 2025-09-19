import '../services/api_service.dart';

class AppStatusService {
  static bool _isBackendAvailable = false;
  static DateTime? _lastCheck;
  
  static bool get isBackendAvailable => _isBackendAvailable;
  
  static Future<bool> checkBackendStatus() async {
    // Don't check too frequently
    if (_lastCheck != null && 
        DateTime.now().difference(_lastCheck!).inMinutes < 5) {
      return _isBackendAvailable;
    }
    
    try {
      print('🔍 Checking backend status at: http://localhost:3000/health');
      final apiService = ApiService();
      final response = await apiService.get('/health').timeout(const Duration(seconds: 5));
      print('✅ Backend response received: $response');
      _isBackendAvailable = true;
      _lastCheck = DateTime.now();
      return true;
    } catch (e) {
      print('❌ Backend check failed: $e');
      _isBackendAvailable = false;
      _lastCheck = DateTime.now();
      return false;
    }
  }
  
  static void setBackendStatus(bool isAvailable) {
    _isBackendAvailable = isAvailable;
    _lastCheck = DateTime.now();
  }
}