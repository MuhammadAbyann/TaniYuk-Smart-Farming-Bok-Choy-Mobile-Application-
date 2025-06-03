import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
import 'package:smartfarmingpakcoy_apps/pages/sensor_data.dart';
import 'dart:async';

class LightIntensityPage extends StatefulWidget {
  const LightIntensityPage({super.key});

  @override
  State<LightIntensityPage> createState() => _LightIntensityPageState();
}

class _LightIntensityPageState extends State<LightIntensityPage> {
  List<SensorData> _sensorData = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchSensorData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _fetchSensorData() async {
    try {
      final newData = await ApiClient.getDailySensorData();
      if (newData.isNotEmpty) {
        // Urutkan ascending berdasarkan waktu
        newData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        setState(() {
          // Ambil 10 data terakhir
          _sensorData = newData.length > 10 ? newData.sublist(newData.length - 10) : newData;
        });
      }
    } catch (e) {
      print('Error fetching light intensity data: $e');
    }
  }

  List<FlSpot> _createChartData() {
    return _sensorData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.lux ?? 0);
    }).toList();
  }

  String _getStatusText(double? lux) {
    if (lux == null) return "Tidak ada data";
    if (lux > 1000) return "Terang";
    if (lux > 300) return "Sedang";
    return "Redup";
  }

  @override
  Widget build(BuildContext context) {
    final latestLux = _sensorData.isNotEmpty ? _sensorData.last.lux : null;
    final chartData = _createChartData();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        title: const Text('Monitoring Intensitas Cahaya'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
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
                      Icons.wb_sunny,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Grafik dinamis intensitas cahaya
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: chartData.isNotEmpty
                    ? LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: chartData.length.toDouble() - 1,
                          minY: 0,
                          maxY: 1500,
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartData,
                              isCurved: true,
                              color: Colors.orange[700]!,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      )
                    : const Center(child: Text("Tidak ada data yang tersedia")),
              ),
              const SizedBox(height: 20),

              // Status intensitas cahaya berdasarkan nilai terakhir
              Text(
                'Status Intensitas Cahaya: ${_getStatusText(latestLux)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 20),

              // Statistik dummy, bisa kamu ganti dengan data real jika ada
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
