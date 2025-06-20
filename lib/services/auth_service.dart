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
    }, requireAuth: true);

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
    }, requireAuth: true);

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

  // Mengirim permintaan lupa password ke backend
  // Pastikan fungsi ini hanya digunakan saat token tidak diperlukan
  static Future<void> forgotPassword(String email) async {
    try {
      final response = await ApiClient.post(
        '/api/forgot-password',  // Endpoint API reset password
        {'email': email},        // Kirimkan email ke backend
        requireAuth: false,      // Jangan kirimkan token karena tidak diperlukan
      );

      if (response != null) {
        print('Permintaan reset password berhasil');
      } else {
        print('Gagal mengirim permintaan');
      }
    } catch (e) {
      print('Error: $e');  // Tambahkan log untuk menangani kesalahan
    }
  }
}
