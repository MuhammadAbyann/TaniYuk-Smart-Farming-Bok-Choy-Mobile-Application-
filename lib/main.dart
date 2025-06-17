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
  bool? isOfflineMode; // Untuk mengecek apakah mode offline atau online
  bool isChecking = false; // Untuk status pengecekan koneksi

  @override
  void initState() {
    super.initState();
    _checkConnectionToESP(); // Langsung cek saat aplikasi mulai
  }

  // Fungsi untuk mengecek koneksi ke ESP32
  Future<void> _checkConnectionToESP() async {
    setState(() {
      isChecking = true; // Menandakan aplikasi sedang mengecek koneksi
    });

    const espUrl = 'http://192.168.4.1/'; // URL ESP32

    try {
      debugPrint("🔍 Cek koneksi ke ESP32...");
      final response = await http
          .get(Uri.parse(espUrl))
          .timeout(const Duration(seconds: 3)); // Timeout 3 detik

      if (response.statusCode == 200 &&
          response.body.contains("Kontrol Manual Relay")) { // Pastikan ada kata kunci yang menunjukkan ESP32
        debugPrint("✅ Terhubung ke ESP32 (Offline Mode)");
        setState(() {
          isOfflineMode = true; // Mode offline (terhubung ke ESP32)
          isChecking = false;
        });
        return;
      }
    } catch (e) {
      debugPrint("❌ Gagal koneksi ke ESP32: $e");
    }

    debugPrint("🌐 Mode ONLINE");
    setState(() {
      isOfflineMode = false; // Jika gagal terhubung ke ESP32, online mode
      isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming Pakcoy',
      debugShowCheckedModeBanner: false,
      home: isOfflineMode == null || isChecking // Tampilkan loading saat mengecek koneksi
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()), // Menunggu status offline/online
            )
          : isOfflineMode! // Jika mode offline
              ? const OfflineControlPage()
              : HomePage(), // Jika mode online, pindah ke HomePage
    );
  }
}
