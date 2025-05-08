import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Untuk menampilkan grafik

class LightIntensityPage extends StatefulWidget {
  const LightIntensityPage({super.key});

  @override
  State<LightIntensityPage> createState() => _LightIntensityPageState();
}

class _LightIntensityPageState extends State<LightIntensityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[700], // Warna kuning/orange untuk cahaya
        title: const Text('Monitoring Intensitas Cahaya'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Logo Matahari dengan Background Biru (mewakili cahaya)
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color:
                      Colors.yellow[100], // Background kuning lembut untuk logo
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange[700]!, width: 3),
                ),
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.orange[700],
                    child: const Icon(
                      Icons.wb_sunny, // Ikon matahari untuk simbol cahaya
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Grafik Intensitas Cahaya
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      Colors
                          .orange[50], // Background kuning lembut untuk grafik
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 3),
                          FlSpot(1, 1.5),
                          FlSpot(2, 2),
                          FlSpot(3, 1.8),
                          FlSpot(4, 2.8),
                        ],
                        isCurved: true,
                        color: Colors.orange[700]!,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Status Intensitas Cahaya
              Text(
                'Status Intensitas Cahaya: Terang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      Colors
                          .orange[700], // Memberikan warna yang konsisten dengan tema
                ),
              ),
              const SizedBox(height: 20),

              // Menampilkan Statistik Intensitas Cahaya (Rata-rata, Perubahan)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Statistik Intensitas Cahaya:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text("Rata-rata Intensitas Cahaya: 3000 lux"),
                    SizedBox(height: 10),
                    Text("Perubahan Selama 24 Jam: +10%"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
