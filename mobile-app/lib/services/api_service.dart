import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Use localhost for Web/Chrome, 10.0.2.2 for Android emulator
  static String get _defaultBaseUrl =>
      kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
  static String get _configuredBaseUrl {
    const fromEnv = String.fromEnvironment('PHISHSHIELD_API_URL');
    return fromEnv.isNotEmpty ? fromEnv : _defaultBaseUrl;
  }
  final String baseUrl;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? _configuredBaseUrl;

  Future<Map<String, dynamic>> scanLink(
    String targetUrl, {
    Map<String, String> deviceProfile = const {},
  }) async {
    return _scanPayload({
      'url': targetUrl,
      'platform': 'mobile',
      ...deviceProfile,
    });
  }

  Future<Map<String, dynamic>> scanText(
    String text, {
    Map<String, String> deviceProfile = const {},
  }) async {
    return _scanPayload({
      'text': text,
      'platform': 'mobile',
      ...deviceProfile,
    });
  }

  Future<Map<String, dynamic>> getTelemetry({
    required String deviceId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/telemetry').replace(
      queryParameters: {'device_id': deviceId},
    );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return {
          ...jsonDecode(response.body) as Map<String, dynamic>,
          'success': true,
        };
      }
      return {
        'success': false,
        'error': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      return {'success': false, 'error': 'Connection failed: $e'};
    }
  }

  Future<Map<String, dynamic>> _scanPayload(
    Map<String, Object?> payload,
  ) async {
    final uri = Uri.parse('$baseUrl/api/scan');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return {
          ...jsonDecode(response.body) as Map<String, dynamic>,
          'success': true,
        };
      }
      final body = jsonDecode(response.body);
      String errorMessage = 'Server error: ${response.statusCode}';
      if (body is Map<String, dynamic> && body['message'] != null) {
        errorMessage = body['message'].toString();
      }
      return {
        if (body is Map<String, dynamic>) ...body,
        'success': false,
        'verdict': body is Map && body['status'] == 'INVALID_INPUT' ? 'INVALID_INPUT' : 'ERROR',
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed: ${e.toString()}',
        'verdict': 'ERROR',
      };
    }
  }
}
