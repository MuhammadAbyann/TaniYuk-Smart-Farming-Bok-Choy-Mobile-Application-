import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartfarmingpakcoy_apps/pages/home_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/offline_control_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/admin_dashboard_page.dart';
import 'package:smartfarmingpakcoy_apps/services/auth_service.dart';
import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
// import 'package:smartfarmingpakcoy_apps/models/user.dart';

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
  bool isChecking = true;
  Widget? nextPage;

  @override
  void initState() {
    super.initState();
    _determineMode();
  }

  Future<void> _determineMode() async {
    const espUrl = 'http://192.168.4.1/';

    try {
      final response = await http
          .get(Uri.parse(espUrl))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 &&
          response.body.contains("Kontrol Manual Relay")) {
        setState(() {
          isOfflineMode = true;
          nextPage = const OfflineControlPage();
          isChecking = false;
        });
        return;
      }
    } catch (_) {}

    // Jika ONLINE: cek role dari profile
    final token = await AuthService.getToken();
    if (token != null) {
      try {
        final user = await ApiClient.getUserProfile();
        setState(() {
          nextPage = (user.role == 'admin')
              ? const AdminDashboardPage()
              : const HomePage();
          isChecking = false;
        });
      } catch (e) {
        setState(() {
          nextPage = const HomePage();
          isChecking = false;
        });
      }
    } else {
      setState(() {
        nextPage = const HomePage();
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming Pakcoy',
      debugShowCheckedModeBanner: false,
      home: isChecking
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : nextPage!,
    );
  }
}
