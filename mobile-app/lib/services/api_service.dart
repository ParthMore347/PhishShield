import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator loopback to host localhost
  static const String _defaultBaseUrl = 'http://10.0.2.2:8000';
  final String baseUrl;

  ApiService({this.baseUrl = _defaultBaseUrl});

  /// Sends a URL to PhishShield Core Engine to analyze for threats
  Future<Map<String, dynamic>> scanLink(String targetUrl) async {
    final uri = Uri.parse('$baseUrl/api/scan');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'url': targetUrl,
          'platform': 'mobile',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
          'verdict': 'UNKNOWN'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed: ${e.toString()}',
        'verdict': 'OFFLINE'
      };
    }
  }
}
