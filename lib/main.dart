import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // pastikan path sudah benar ke splash_screen.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Ganti WelcomePage jadi SplashScreen
    );
  }
}