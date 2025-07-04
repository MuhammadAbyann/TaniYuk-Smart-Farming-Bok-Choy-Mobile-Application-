import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smartfarmingpakcoy_apps/pages/welcome_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/home_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/admin_dashboard_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/offline_control_page.dart';
import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
import 'package:http/http.dart' as http;

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
  Widget? initialPage;
  bool hasNavigated = false; // 🔐 Prevent multiple navigation
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initApp();

    // 🔁 Cek perubahan koneksi secara realtime
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.wifi)) {
        _checkConnectionToESP(forceRefresh: true);
      }
    });
  }

  Future<void> _initApp() async {
    await _checkConnectionToESP();
    if (isOfflineMode == true) {
      setState(() {
        initialPage = const OfflineControlPage();
        isChecking = false;
        hasNavigated = true;
      });
    } else {
      await _checkAuthStatus();
    }
  }

  Future<void> _checkConnectionToESP({bool forceRefresh = false}) async {
    if (!forceRefresh && isOfflineMode != null) return;
    if (hasNavigated) return;

    const espUrl = 'http://192.168.4.1/';
    try {
      final response = await http
          .get(Uri.parse(espUrl))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200 &&
          response.body.contains("Kontrol Manual Relay")) {
        debugPrint("✅ Terhubung ke ESP32 (Offline Mode)");
        if (!hasNavigated) {
          setState(() {
            isOfflineMode = true;
            initialPage = const OfflineControlPage();
            isChecking = false;
            hasNavigated = true;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint("❌ Tidak bisa konek ke ESP32: $e");
    }

    debugPrint("🌐 Masuk ke Mode Online");
    isOfflineMode = false;
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    if (hasNavigated) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      try {
        final user = await ApiClient.getUserProfile();
        if (user.role == 'admin') {
          initialPage = const AdminDashboardPage();
        } else {
          initialPage = const HomePage();
        }
      } catch (_) {
        initialPage = const WelcomePage();
      }
    } else {
      initialPage = const WelcomePage();
    }

    setState(() {
      isChecking = false;
      hasNavigated = true;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming Pakcoy',
      debugShowCheckedModeBanner: false,
      home: isChecking
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : initialPage!,
    );
  }
}
