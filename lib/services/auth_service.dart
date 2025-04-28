import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';

  // Register User
  static Future<void> register({
    required String email,
    required String password,
    required String role,
  }) async {
    await ApiClient.post('/api/auth/register', {
      'email': email,
      'password': password,
      'role': role,
    });
  }

  // Login User
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post('/api/auth/login', {
      'email': email,
      'password': password,
    });

    final token = response['token'];
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } else {
      throw Exception('Token tidak ditemukan saat login');
    }
  }

  // Logout User
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  // Ambil token yang disimpan
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // (Optional) Forgot Password (dummy)
  static Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
