import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:smartfarmingpakcoy_apps/pages/home_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/offline_control_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/admin_dashboard_page.dart';

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
  Widget? startPage;

  @override
  void initState() {
    super.initState();
    _checkConnectionToESP();
  }

  Future<void> _checkConnectionToESP() async {
    setState(() {
      isChecking = true;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.4.1/')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200 && response.body.contains("Kontrol Manual Relay")) {
        setState(() {
          isOfflineMode = true;
          isChecking = false;
        });
        return;
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? 'user';
    setState(() {
      isOfflineMode = false;
      isChecking = false;
      startPage = (role == 'admin') ? const AdminDashboardPage() : const HomePage();
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
              : startPage ?? const HomePage(),
    );
  }
}
