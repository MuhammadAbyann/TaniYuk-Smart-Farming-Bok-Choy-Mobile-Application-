import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Untuk menampilkan grafik

class FertilizerControlPage extends StatefulWidget {
  const FertilizerControlPage({super.key});

  @override
  State<FertilizerControlPage> createState() => _FertilizerControlPageState();
}

class _FertilizerControlPageState extends State<FertilizerControlPage> {
  String selectedAmount = 'Sedikit';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700], // Hijau tua untuk app bar
        title: const Text('Kontrol Pemupukan'),
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
              // Logo bunga berbentuk lingkaran di atas dengan background yang lebih soft
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color:
                      Colors.green[100], // Background hijau lembut untuk logo
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green[700]!, width: 3),
                ),
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.green[700],
                    child: Icon(
                      Icons.local_florist,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Grafik Monitoring dengan background yang lebih jelas
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      Colors.green[50], // Background hijau lembut untuk grafik
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

              // Pilihan Jumlah Pemupukan dengan background yang lebih jelas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      Colors
                          .green[50], // Background lebih soft untuk tombol pemupukan
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

              // Tombol Jalankan Pemupukan yang lebih menonjol
              ElevatedButton(
                onPressed: () {
                  // Aksi ketika tombol jalankan diklik
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pemupukan Berhasil Dilakukan'),
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

  // Fungsi untuk membuat tombol pilihan jumlah pemupukan dengan ikon
  Widget _buildAmountButton(String amount, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAmount = amount; // Update pilihan jumlah pemupukan
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              selectedAmount == amount ? Colors.green[700] : Colors.transparent,
          border: Border.all(color: Colors.green[700]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color:
                  selectedAmount == amount ? Colors.white : Colors.green[700],
            ),
            const SizedBox(height: 5),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                color:
                    selectedAmount == amount ? Colors.white : Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
