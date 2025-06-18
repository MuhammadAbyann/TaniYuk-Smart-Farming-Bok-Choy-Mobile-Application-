import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'token';
  static const _roleKey = 'role';

  // Register User
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post('/api/auth/register', {
      'email': email,
      'password': password,
    });

    return response;
  }

  // Login User
  static Future<String> login({
  required String email,
  required String password,
}) async {
  final response = await ApiClient.post('/api/auth/login', {
    'email': email,
    'password': password,
  });

  final token = response['token'];
  if (token != null && token is String) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    // Ambil profile dan simpan role
    final user = await ApiClient.getUserProfile();
    await prefs.setString('role', user.role ?? 'user'); // ⬅️ Simpan role

    return token;
  } else {
    throw Exception('Token tidak ditemukan saat login');
  }
}

  // Logout User
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
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

  // Ambil role yang disimpan
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Dummy forgot password
  static Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
