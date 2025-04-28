import 'package:flutter/material.dart';
import 'dart:async';

class FertilizerControlPage extends StatefulWidget {
  const FertilizerControlPage({super.key});

  @override
  State<FertilizerControlPage> createState() => _FertilizerControlPageState();
}

class _FertilizerControlPageState extends State<FertilizerControlPage> {
  String selectedMode = 'Otomatis';
  double nutrientLevel = 0.75; // Dummy kadar nutrisi 75%

  @override
  void initState() {
    super.initState();
    _simulateSensor();
  }

  // Simulasi data sensor nutrisi
  void _simulateSensor() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        nutrientLevel = (nutrientLevel + 0.05) % 1.0;
      });
    });
  }

  void _setMode(String mode) {
    setState(() {
      selectedMode = mode;
    });
  }

  void _startFertilizing() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: Text('Mulai pemupukan mode: $selectedMode?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pemupukan $selectedMode dijalankan!'),
                    ),
                  );
                },
                child: const Text('Jalankan'),
              ),
            ],
          ),
    );
  }

  Widget _buildSelector(String label, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () => _setMode(label),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selectedMode == label ? Colors.redAccent : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.brown[300],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Kontrol Pemupukan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green[300],
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                ),
                                _buildSelector(
                                  'Otomatis',
                                  const Alignment(0, -1.2),
                                ),
                                _buildSelector(
                                  'Banyak',
                                  const Alignment(-1.2, 0),
                                ),
                                _buildSelector(
                                  'Sedikit',
                                  const Alignment(1.2, 0),
                                ),
                                _buildSelector(
                                  'Sedang',
                                  const Alignment(0, 1.2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _startFertilizing,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[200],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'JALANKAN',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.brown[300],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: CircularProgressIndicator(
                                      value: nutrientLevel,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.white24,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                  Text(
                                    "${(nutrientLevel * 100).toInt()}%",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Kadar Nutrisi',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF184C45),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.bar_chart, color: Colors.white),
            Icon(Icons.home, color: Colors.white),
            Icon(Icons.person, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
