import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late http.Client _client;
  String? _authToken;

  void initialize() {
    _client = http.Client();
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Generic request method
  Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(endpoint));
      final uriWithQuery = queryParams != null 
          ? uri.replace(queryParameters: queryParams)
          : uri;

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(
            uriWithQuery,
            headers: _headers,
          ).timeout(ApiConfig.connectionTimeout);
          break;
        case 'POST':
          response = await _client.post(
            uriWithQuery,
            headers: _headers,
            body: data != null ? jsonEncode(data) : null,
          ).timeout(ApiConfig.connectionTimeout);
          break;
        case 'PUT':
          response = await _client.put(
            uriWithQuery,
            headers: _headers,
            body: data != null ? jsonEncode(data) : null,
          ).timeout(ApiConfig.connectionTimeout);
          break;
        case 'DELETE':
          response = await _client.delete(
            uriWithQuery,
            headers: _headers,
          ).timeout(ApiConfig.connectionTimeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on http.ClientException {
      throw ApiException('Network error occurred');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    try {
      final decodedBody = jsonDecode(body);
      
      if (statusCode >= 200 && statusCode < 300) {
        return decodedBody;
      } else {
        final errorMessage = decodedBody['error'] ?? 
                           decodedBody['message'] ?? 
                           'Unknown error occurred';
        throw ApiException(
          errorMessage,
          statusCode: statusCode,
          data: decodedBody,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Failed to parse response',
        statusCode: statusCode,
        data: body,
      );
    }
  }

  // Convenience methods
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) {
    return _request('GET', endpoint, queryParams: queryParams);
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) {
    return _request('POST', endpoint, data: data);
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) {
    return _request('PUT', endpoint, data: data);
  }

  Future<dynamic> delete(String endpoint) {
    return _request('DELETE', endpoint);
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.healthUrl),
        headers: ApiConfig.defaultHeaders,
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}