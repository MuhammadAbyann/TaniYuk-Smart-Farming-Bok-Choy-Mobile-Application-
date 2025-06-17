import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../api/api_client.dart';
import '../pages/sensor_data.dart';

class WateringControlPage extends StatefulWidget {
  const WateringControlPage({super.key});

  @override
  State<WateringControlPage> createState() => _WateringControlPageState();
}

class _WateringControlPageState extends State<WateringControlPage> {
  late Future<List<SensorData>> sensorFuture;
  double waterVolume = 0.0;
  bool isOn = false;
  bool isAuto = false;

  @override
  void initState() {
    super.initState();
    sensorFuture = ApiClient.getDailySensorData();
    fetchWaterVolume();
  }

  Future<void> fetchWaterVolume() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.4.1/api/sensor/total-volume'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          waterVolume = double.tryParse(jsonData['totalVolume'].toString()) ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint('Gagal mengambil volume air: $e');
    }
  }

  Future<void> sendManualCommand(bool turnOn) async {
    final url = Uri.parse('http://192.168.4.1/watering/${turnOn ? 'on' : 'off'}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Manual: ${response.body}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal manual: ${response.statusCode}')));
      }
      await fetchWaterVolume();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> sendAutoCommand() async {
    final url = Uri.parse('http://192.168.4.1/watering/auto');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Otomatis: ${response.body}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal auto: ${response.statusCode}')));
      }
      await fetchWaterVolume();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void toggleManual() {
    setState(() {
      isOn = !isOn;
      isAuto = false;
    });
    sendManualCommand(isOn);
  }

  void toggleAuto() {
    setState(() {
      isAuto = true;
      isOn = false;
    });
    sendAutoCommand();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrol Penyiraman'),
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                color: Colors.blue[300],
                border: Border.all(color: Colors.blue[700]!, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[700],
                    border: Border.all(color: Colors.white, width: 5),
                  ),
                  child: const Icon(Icons.water_drop, color: Colors.white, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 30),
            FutureBuilder<List<SensorData>>(
              future: sensorFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return SizedBox(height: 150, child: Center(child: Text('Error: ${snapshot.error}')));
                }

                final data = snapshot.data ?? [];
                final chartData = data.asMap().entries.map(
                  (entry) => FlSpot(entry.key.toDouble(), entry.value.averageSoilMoisture),
                ).toList();

                if (chartData.isEmpty) {
                  return const SizedBox(height: 150, child: Center(child: Text("Tidak ada data yang tersedia")));
                }

                return Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
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
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: true,
                          color: Colors.lightBlueAccent,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                          barWidth: 3,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.opacity, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(
                    'Volume Air Keluar: ',
                    style: TextStyle(fontSize: 16, color: Colors.blue[800], fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${waterVolume.toStringAsFixed(2)} L',
                    style: TextStyle(fontSize: 16, color: Colors.blue[900], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[700],
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
                          color: isOn ? Colors.lightBlue[100] : Colors.blue[300],
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Text(
                            isOn ? 'OFF' : 'ON',
                            style: TextStyle(color: isOn ? Colors.blue[700] : Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
                          color: isAuto ? Colors.lightBlue[100] : Colors.blue[50],
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Text(
                            isAuto ? 'OTOMATIS ON' : 'OTOMATIS OFF',
                            style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 16),
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
