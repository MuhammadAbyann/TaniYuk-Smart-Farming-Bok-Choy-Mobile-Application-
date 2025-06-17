import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartfarmingpakcoy_apps/pages/home_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/offline_control_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/admin_dashboard_page.dart'; // 🆕 import halaman admin
import 'package:smartfarmingpakcoy_apps/services/auth_service.dart';
import 'package:smartfarmingpakcoy_apps/api/api_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isOfflineMode;
  bool isChecking = false;
  Widget? nextPage; // 🆕 Halaman tujuan (admin/home)

  @override
  void initState() {
    super.initState();
    _checkConnectionToESP();
  }

  Future<void> _checkConnectionToESP() async {
    setState(() {
      isChecking = true;
    });

    const espUrl = 'http://192.168.4.1/';

    try {
      final response = await http.get(Uri.parse(espUrl)).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200 && response.body.contains("Kontrol Manual Relay")) {
        setState(() {
          isOfflineMode = true;
          isChecking = false;
        });
        return;
      }
    } catch (_) {}

    // ONLINE MODE
    setState(() {
      isOfflineMode = false;
    });

    // 🆕 Ambil token dan cek role user
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        nextPage = const HomePage(); // fallback kalau belum login
      } else {
        final user = await ApiClient.getUserProfile();
        if (user.role == 'admin') {
          nextPage = const AdminDashboardPage(); // ⬅️ masuk admin
        } else {
          nextPage = const HomePage(); // ⬅️ masuk user biasa
        }
      }
    } catch (e) {
      nextPage = const HomePage(); // fallback jika error
    }

    setState(() {
      isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming Pakcoy',
      debugShowCheckedModeBanner: false,
      home: isOfflineMode == null || isChecking
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : isOfflineMode!
              ? const OfflineControlPage()
              : nextPage ?? const HomePage(), // 🆕 arahkan sesuai role
    );
  }
}
