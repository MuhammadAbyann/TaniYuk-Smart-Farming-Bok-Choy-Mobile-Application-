import 'package:flutter/material.dart';
import 'watering_page.dart';
import 'fertilize_page.dart';

class OfflineControlPage extends StatelessWidget {
  const OfflineControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrol Offline'),
        backgroundColor: Colors.teal[700],
      ),
      backgroundColor: const Color(0xFFF8F4FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WateringControlPage()),
                );
              },
              icon: const Icon(Icons.water_drop),
              label: const Text('Penyiraman'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FertilizerControlPage()),
                );
              },
              icon: const Icon(Icons.local_florist),
              label: const Text('Pemupukan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
