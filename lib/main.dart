import 'package:flutter/material.dart';
import 'pages/welcome_page.dart'; // pastikan ini sesuai path file kamu

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming',
      home: const WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
