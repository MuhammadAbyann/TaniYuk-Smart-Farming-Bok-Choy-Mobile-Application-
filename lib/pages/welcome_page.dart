import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

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

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Gambar bagian atas
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                SizedBox.expand(
                  child: Image.asset(
                    'assets/images/farming.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ],
            ),
          ),
          // Konten bawah
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F8F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Google
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Image.asset('assets/images/google.png', height: 24),
                      label: const Text(
                        'Lanjutkan dengan Google',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tombol Buat Akun
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Buat Akun'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF197C58),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  // Text Masuk
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah memiliki akun? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
