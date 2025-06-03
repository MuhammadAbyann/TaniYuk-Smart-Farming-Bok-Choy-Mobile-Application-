import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
import 'package:smartfarmingpakcoy_apps/pages/sensor_data.dart';

class FertilizerControlPage extends StatefulWidget {
  const FertilizerControlPage({super.key});

  @override
  State<FertilizerControlPage> createState() => _FertilizerControlPageState();
}

class _FertilizerControlPageState extends State<FertilizerControlPage> {
  late Future<List<SensorData>> sensorFuture;
  bool isOn = false;
  bool isAuto = false;

  @override
  void initState() {
    super.initState();
    sensorFuture = ApiClient.getDailySensorData();
  }

  Future<void> sendManualCommand(bool turnOn) async {
    final url = Uri.parse("http://192.168.4.1/manual_pupuk?status=${turnOn ? 'on' : 'off'}");
    try {
      final response = await http.get(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Manual: ${response.body}')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim perintah manual')),
      );
    }
  }

  Future<void> sendAutoCommand(bool turnOn) async {
    final url = Uri.parse("http://192.168.4.1/auto_pupuk?status=${turnOn ? 'on' : 'off'}");
    try {
      final response = await http.get(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Otomatis: ${response.body}')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim perintah otomatis')),
      );
    }
  }

  void toggleManual() async {
    setState(() {
      isOn = !isOn;
      isAuto = false;
    });
    await sendManualCommand(isOn);
  }

  void toggleAuto() async {
    setState(() {
      isAuto = !isAuto;
      isOn = false;
    });
    await sendAutoCommand(isAuto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrol Pemupukan'),
        backgroundColor: Colors.green[800],
      ),
      backgroundColor: const Color(0xFFF8F4FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[300],
                border: Border.all(color: Colors.green[700]!, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green[700],
                    border: Border.all(color: Colors.white, width: 5),
                  ),
                  child: const Icon(
                    Icons.local_florist,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            FutureBuilder<List<SensorData>>(
              future: sensorFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SizedBox(
                    height: 150,
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else {
                  final data = snapshot.data ?? [];
                  final chartData = data.asMap().entries.map(
                    (entry) => FlSpot(entry.key.toDouble(), entry.value.phSensor ?? 0),
                  ).toList();

                  if (chartData.isEmpty) {
                    return const SizedBox(
                      height: 150,
                      child: Center(child: Text("Tidak ada data yang tersedia")),
                    );
                  }

                  return Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: chartData.length.toDouble() - 1,
                        minY: 0,
                        maxY: 14,
                        lineBarsData: [
                          LineChartBarData(
                            spots: chartData,
                            isCurved: true,
                            color: Colors.lightGreenAccent,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: toggleManual,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isOn ? Colors.green[100] : Colors.green[300],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isOn ? 'OFF' : 'ON',
                            style: TextStyle(
                              color: isOn ? Colors.green[800] : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: toggleAuto,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isAuto ? Colors.green[100] : Colors.green[50],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isAuto ? 'OTOMATIS ON' : 'OTOMATIS OFF',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
