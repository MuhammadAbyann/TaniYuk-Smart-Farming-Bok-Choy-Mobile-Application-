import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartfarmingpakcoy_apps/pages/home_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/offline_control_page.dart';

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

  @override
  void initState() {
    super.initState();
    _checkConnectionToESP();
  }

  Future<void> _checkConnectionToESP() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.4.1/ping'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200 && response.body.trim() == "pong") {
        setState(() => isOfflineMode = true);
        return;
      }
    } catch (_) {}
    setState(() => isOfflineMode = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming Pakcoy',
      debugShowCheckedModeBanner: false,
      home: isOfflineMode == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : isOfflineMode!
              ? const OfflineControlPage()
              : const HomePage(),
    );
  }
}
