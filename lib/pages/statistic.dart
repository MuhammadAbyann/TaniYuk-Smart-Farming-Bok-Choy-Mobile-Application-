import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
import 'package:smartfarmingpakcoy_apps/pages/sensor_data.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  late Future<List<SensorData>> sensorFuture;

  @override
  void initState() {
    super.initState();
    sensorFuture = ApiClient.getDailySensorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<SensorData>>(
          future: sensorFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final data = snapshot.data!;
              data.sort((a, b) => a.timestamp.compareTo(b.timestamp));
              final lastTenData = data.length > 10 ? data.sublist(data.length - 10) : data;
              final soilMoistureValues = _calcSoilMoisture(lastTenData);
              final latestData = lastTenData.isNotEmpty ? lastTenData.last : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SensorChart(
                      title: 'Intensitas Cahaya',
                      chartData: _createChartData(
                        lastTenData.map((d) => d.lux ?? 0.0).toList(),
                      ),
                      value: latestData?.lux ?? 0.0,
                      indicatorColor: Colors.yellow,
                    ),
                    const SizedBox(height: 20),
                    SensorChart(
                      title: 'Kelembapan Tanah',
                      chartData: _createChartData(soilMoistureValues),
                      value: soilMoistureValues.isNotEmpty ? soilMoistureValues.last : 0.0,
                      indicatorColor: Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    SensorChart(
                      title: 'pH Tanah',
                      chartData: _createChartData(
                        lastTenData.map((d) => d.phSensor ?? 0.0).toList(),
                      ),
                      value: latestData?.phSensor ?? 0.0,
                      indicatorColor: Colors.red,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  List<double> _calcSoilMoisture(List<SensorData> data) {
    return data.map((d) {
      final values = [
        d.nanoMoisture1 ?? 0,
        d.nanoMoisture2 ?? 0,
        d.nanoMoisture3 ?? 0,
        d.soilMoisture1 ?? 0,
        d.soilMoisture2 ?? 0,
      ];
      final count = values.where((v) => v > 0).length;
      if (count == 0) return 0.0;
      return values.reduce((a, b) => a + b) / count;
    }).toList();
  }

  List<FlSpot> _createChartData(List<double> values) {
    return values.asMap().entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }
}

class SensorChart extends StatelessWidget {
  final String title;
  final List<FlSpot> chartData;
  final double value;
  final Color indicatorColor;

  const SensorChart({
    required this.title,
    required this.chartData,
    required this.value,
    required this.indicatorColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Monitoring $title",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF184C45),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: chartData.isNotEmpty
              ? LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: true,
                      horizontalInterval: indicatorColor == Colors.red ? 2 : 20,
                      verticalInterval: 5,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: chartData.length.toDouble() - 1,
                    minY: 0,
                    maxY: indicatorColor == Colors.yellow
                        ? 1500
                        : indicatorColor == Colors.blue
                            ? 100
                            : 14,
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: indicatorColor,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                        barWidth: 3,
                      ),
                    ],
                  ),
                )
              : const Center(child: Text("Tidak ada data yang tersedia")),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildStatusIndicator('Tinggi', value > 60 ? Colors.green : Colors.transparent),
            const SizedBox(width: 10),
            _buildStatusIndicator('Sedang', value > 30 && value <= 60 ? Colors.yellow : Colors.transparent),
            const SizedBox(width: 10),
            _buildStatusIndicator('Rendah', value <= 30 ? Colors.red : Colors.transparent),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStatusIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}
