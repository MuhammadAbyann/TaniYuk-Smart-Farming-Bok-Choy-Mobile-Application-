import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartfarmingpakcoy_apps/pages/fertilize_page.dart';
import 'package:smartfarmingpakcoy_apps/pages/watering_page.dart'; // Mengimpor halaman WateringPage

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Mengarahkan ke halaman WateringPage saat Kelembapan dipilih
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const WateringControlPage(), // Ganti ke WateringPage
                    ),
                  );
                },
                child: const MonitoringSection(
                  title: 'Kelembapan',
                  radioOptions: ['Tinggi', 'Sedang', 'Rendah'],
                ),
              ),
              const SizedBox(height: 20),
              const MonitoringSection(
                title: 'Intensitas Cahaya',
                radioOptions: ['Lembab', 'Sedang', 'Kurang'],
              ),
              const SizedBox(height: 20),
              // Tombol Pemupukan yang terhubung ke FertilizerControlPage
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FertilizerControlPage(),
                    ),
                  );
                },
                child: const MonitoringSection(
                  title: 'Pemupukan',
                  radioOptions: ['Banyak', 'Sedang', 'Sedikit'],
                ),
              ),
              const SizedBox(height: 80), // Space bawah biar tidak ketutup nav
            ],
          ),
        ),
      ),
    );
  }
}

class MonitoringSection extends StatefulWidget {
  final String title;
  final List<String> radioOptions;

  const MonitoringSection({
    super.key,
    required this.title,
    required this.radioOptions,
  });

  @override
  State<MonitoringSection> createState() => _MonitoringSectionState();
}

class _MonitoringSectionState extends State<MonitoringSection> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Monitoring
        Text(
          "Monitoring ${widget.title}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Kotak monitoring berisi grafik dummy
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF184C45),
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
        const SizedBox(height: 8),

        // Radio button status
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 10,
          children:
              widget.radioOptions.map((option) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: option,
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                    Text(option),
                  ],
                );
              }).toList(),
        ),
        const SizedBox(height: 8),

        // Tombol kecil di bawah
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                height: 30,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.teal[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 30,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.teal[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
