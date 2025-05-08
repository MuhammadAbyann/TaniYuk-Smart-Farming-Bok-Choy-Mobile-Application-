import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Untuk menampilkan grafik

class WateringControlPage extends StatefulWidget {
  const WateringControlPage({super.key});

  @override
  State<WateringControlPage> createState() => _WateringControlPageState();
}

class _WateringControlPageState extends State<WateringControlPage> {
  String selectedAmount = 'Sedikit';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700], // Warna biru laut untuk tema air
        title: const Text('Kontrol Penyiraman'),
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
              // Logo air berbentuk lingkaran di atas dengan background biru
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.blue[100], // Background biru muda untuk logo
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue[700]!, width: 3),
                ),
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.blue[700],
                    child: Icon(
                      Icons.water_drop,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Grafik Monitoring untuk kelembapan tanah
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[50], // Background biru muda untuk grafik
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
                        color: Colors.white,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Pilihan Jumlah Penyiraman dengan background yang lebih jelas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      Colors
                          .blue[50], // Background lebih soft untuk tombol penyiraman
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAmountButton('Banyak', Icons.water_drop),
                    _buildAmountButton('Sedang', Icons.local_florist),
                    _buildAmountButton('Sedikit', Icons.ac_unit),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pilihan Otomatis (diletakkan di bawah dengan desain yang konsisten)
              _buildAmountButton(
                'Otomatis',
                Icons.autorenew,
              ), // Tombol Otomatis di bawah tombol lainnya

              const SizedBox(height: 30),

              // Tombol Jalankan Penyiraman yang lebih menonjol
              ElevatedButton(
                onPressed: () {
                  // Aksi ketika tombol jalankan diklik
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Penyiraman Berhasil Dilakukan'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Memberikan warna mencolok
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 18,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation:
                      10, // Memberikan bayangan agar tombol lebih menonjol
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Sudut lebih melengkung
                  ),
                ),
                child: const Text('Jalankan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membuat tombol pilihan jumlah penyiraman dengan ikon
  Widget _buildAmountButton(String amount, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAmount = amount; // Update pilihan jumlah penyiraman
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              selectedAmount == amount ? Colors.blue[700] : Colors.transparent,
          border: Border.all(color: Colors.blue[700]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: selectedAmount == amount ? Colors.white : Colors.blue[700],
            ),
            const SizedBox(height: 5),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                color:
                    selectedAmount == amount ? Colors.white : Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
