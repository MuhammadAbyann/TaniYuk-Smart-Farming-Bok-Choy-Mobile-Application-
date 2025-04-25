import 'package:flutter/material.dart';
import 'dart:async';
import 'register_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 1;
  String selectedInterval = 'Weekly';

  double kelembapan = 72;
  double phTanah = 6.4;
  double intensitasCahaya = 1200;

  @override
  void initState() {
    super.initState();
    _autoRefresh();
  }

  void _autoRefresh() {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        // Simulasi update data
        kelembapan = (kelembapan + 1) % 100;
        phTanah = 6 + (kelembapan % 10) / 10;
        intensitasCahaya = 1000 + (kelembapan * 5);
      });
    });
  }

  Widget _buildMonitoringBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF184C45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Monitoring",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: selectedInterval,
                dropdownColor: const Color(0xFF184C45),
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox(),
                iconEnabledColor: Colors.white,
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedInterval = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Placeholder grafik sederhana
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                "📈 Grafik akan ditampilkan di sini",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicMonitoring() {
    final List<Map<String, dynamic>> basicMonitoringData = [
      {
        'icon': Icons.water_drop,
        'label': 'Kelembapan',
        'value': '${kelembapan.toStringAsFixed(1)}%',
        'color': kelembapan < 50 ? Colors.red[200] : Colors.blue[200],
      },
      {
        'icon': Icons.science,
        'label': 'pH Tanah',
        'value': '${phTanah.toStringAsFixed(1)}',
        'color':
            (phTanah < 5.5 || phTanah > 7)
                ? Colors.red[200]
                : Colors.green[200],
      },
      {
        'icon': Icons.wb_sunny,
        'label': 'Cahaya',
        'value': '${intensitasCahaya.toStringAsFixed(0)} lux',
        'color':
            intensitasCahaya < 800 ? Colors.orange[200] : Colors.amber[200],
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          basicMonitoringData.map((item) {
            return Expanded(
              child: Container(
                height: 100,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item['color'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'], size: 28, color: Colors.black87),
                    const SizedBox(height: 8),
                    Text(
                      item['label'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(item['value'], style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _getBody() {
    switch (selectedIndex) {
      case 0:
        return const Center(
          child: Text("📊 Halaman Statistik", style: TextStyle(fontSize: 18)),
        );
      case 2:
        return const Center(
          child: Text("👤 Profil Pengguna", style: TextStyle(fontSize: 18)),
        );
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back),
                  Column(
                    children: const [
                      Text(
                        "Pakcoy Fields",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Ditanam 1 April 2025",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Color(0xFF184C45),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildMonitoringBox(),
              const SizedBox(height: 20),
              const Text(
                "Basic Monitoring",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildBasicMonitoring(),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _getBody()),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF184C45),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.bar_chart,
                color: selectedIndex == 0 ? Colors.grey[300] : Colors.white,
              ),
              onPressed: () => setState(() => selectedIndex = 0),
            ),
            IconButton(
              icon: Icon(
                Icons.home,
                color: selectedIndex == 1 ? Colors.grey[300] : Colors.white,
              ),
              onPressed: () => setState(() => selectedIndex = 1),
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: selectedIndex == 2 ? Colors.grey[300] : Colors.white,
              ),
              onPressed: () => setState(() => selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}
