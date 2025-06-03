// Tambahkan atau pastikan ini ada di paling atas
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartfarmingpakcoy_apps/services/auth_service.dart';
// import 'package:smartfarmingpakcoy_apps/models/user.dart';
import 'package:smartfarmingpakcoy_apps/pages/sensor_data.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiClient {
  static const String _baseUrl = 'http://34.101.104.19:5000';

  static Future<Map<String, dynamic>> getUserProfile() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return json.decode(response.body);
  }

  static Future<bool> updateUserProfile({
    required String lokasiLahan,
    required String jenisTanaman,
    required String luasLahan,
    required String lamaPanen,
  }) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/api/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'lokasiLahan': lokasiLahan,
        'jenisTanaman': jenisTanaman,
        'luasLahan': luasLahan,
        'lamaPanen': lamaPanen,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
}


  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$_baseUrl$endpoint'));
    return _processResponse(response);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
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
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/sensor/daily'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token ?? '',
      },
    );
    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded.map((json) => SensorData.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<List<SensorData>> getWeeklySensorData() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/sensor/weekly'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token ?? '',
      },
    );
    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded.map((json) => SensorData.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<List<SensorData>> getMonthlySensorData() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/sensor/monthly'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token ?? '',
      },
    );
    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded.map((json) => SensorData.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<SensorData> getLatestSensorData() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/sensor/last'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token ?? '',
      },
    );
    final jsonMap = json.decode(response.body);
    return SensorData.fromJson(jsonMap);
  }
}
