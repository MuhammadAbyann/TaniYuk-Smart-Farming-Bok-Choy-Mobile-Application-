import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  static const String _baseUrl = 'http://10.0.2.2:5000';

  // GET Request
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$_baseUrl$endpoint'));
    return _processResponse(response);
  }

  // POST Request
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return _processResponse(response);
  }

  // PUT, DELETE, etc bisa ditambahkan kalau perlu

  // Internal helper to process the response
  static dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? json.decode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else {
      throw Exception('HTTP Error: $statusCode, $body');
    }
  }
}
