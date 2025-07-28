import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartfarmingpakcoy_apps/services/auth_service.dart';
import 'package:smartfarmingpakcoy_apps/models/user.dart';
import 'package:smartfarmingpakcoy_apps/pages/sensor_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String _baseUrl = 'http://34.101.104.19:5000';

  // Utilitas header bearer
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    print('[DEBUG] Token dari AuthService.getToken(): $token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<User> getUserProfile() async {
    final url = Uri.parse('$_baseUrl/api/user/profile');
    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);

    print('[GET PROFILE] Status Code: ${response.statusCode}');
    print('[GET PROFILE] Body: ${response.body}');

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengambil profil');
    }
  }

  static Future<bool> updateUserProfile(User user) async {
    final url = Uri.parse('$_baseUrl/api/user/profile');
    final headers = await _authHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({
        'lokasiLahan': user.lokasiLahan,
        'jenisTanaman': user.jenisTanaman,
        'luasLahan': user.luasLahan,
        'lamaPanen': user.lamaPanen,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<dynamic> get(String endpoint) async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$_baseUrl$endpoint'), headers: headers);
    return _processResponse(response);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body, {required bool requireAuth}) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
    return _processResponse(response);
  }

  static dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? json.decode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else {
      throw Exception('HTTP Error: $statusCode, $body');
    }
  }

  static Future<List<SensorData>> getDailySensorData() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/sensor/daily'),
      headers: headers,
    );
    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded.map((json) => SensorData.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<List<SensorData>> getWeeklySensorData() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/sensor/weekly'),
      headers: headers,
    );
    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded.map((json) => SensorData.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<List<SensorData>> getMonthlySensorData() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/sensor/monthly'),
      headers: headers,
    );
    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded.map((json) => SensorData.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<SensorData> getLatestSensorData() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/sensor/last'),
      headers: headers,
    );
    final jsonMap = json.decode(response.body);
    return SensorData.fromJson(jsonMap);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
  final headers = await _authHeaders();
  final response = await http.put(
    Uri.parse('$_baseUrl$endpoint'),
    headers: headers,
    body: json.encode(body),
  );
  return _processResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final headers = await _authHeaders();
    final response = await http.delete(Uri.parse('$_baseUrl$endpoint'), headers: headers);
    return _processResponse(response);
  }

  static Future<void> deleteUser(String userId) async {
  final url = Uri.parse('$_baseUrl/admin/users/$userId');
  final response = await http.delete(url, headers: await _authHeaders());

  if (response.statusCode != 200) {
    throw Exception('Gagal menghapus user');
  }
  }

}

