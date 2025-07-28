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
              final lastTenData = data.length > 10
                  ? data.sublist(data.length - 10)
                  : (data.isEmpty ? List.generate(10, (_) => SensorData.empty()) : data);
              final latestData = lastTenData.isNotEmpty ? lastTenData.last : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildChart(
                      title: 'Intensitas Cahaya',
                      data: lastTenData.map((e) => e.lux ?? 0).toList(),
                      color: Colors.yellow,
                      value: latestData?.lux ?? 0,
                    ),
                    _buildChart(
                      title: 'Debit Air',
                      data: lastTenData.map((e) => e.flowRate ?? 0).toList(),
                      color: Colors.green,
                      value: latestData?.flowRate ?? 0,
                    ),
                    _buildChart(
                      title: 'Temperatur',
                      data: lastTenData.map((e) => e.temperature ?? 0).toList(),
                      color: Colors.purple,
                      value: latestData?.temperature ?? 0,
                    ),
                    _buildChart(
                      title: 'Kelembapan Udara',
                      data: lastTenData.map((e) => e.humidity ?? 0).toList(),
                      color: Colors.cyan,
                      value: latestData?.humidity ?? 0,
                    ),
                    _buildChart(
                      title: 'Kelembapan Bedeng 1',
                      data: lastTenData.map((e) => e.bedeng1.averageMoisture).toList(),
                      color: Colors.blue,
                      value: latestData?.bedeng1.averageMoisture ?? 0,
                    ),
                    _buildChart(
                      title: 'Kelembapan Bedeng 2',
                      data: lastTenData.map((e) => e.bedeng2.averageMoisture).toList(),
                      color: Colors.lightBlueAccent,
                      value: latestData?.bedeng2.averageMoisture ?? 0,
                    ),
                    _buildChart(
                      title: 'pH Bedeng 1',
                      data: lastTenData.map((e) => e.bedeng1.phSensor ?? 0).toList(),
                      color: Colors.red,
                      value: latestData?.bedeng1.phSensor ?? 0,
                    ),
                    _buildChart(
                      title: 'pH Bedeng 2',
                      data: lastTenData.map((e) => e.bedeng2.pHNano ?? 0).toList(),
                      color: Colors.orange,
                      value: latestData?.bedeng2.pHNano ?? 0,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildChart({
    required String title,
    required List<double> data,
    required Color color,
    required double value,
  }) {
    final chartData = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    double maxY = chartData.isNotEmpty
        ? chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 100.0;
    double minY = chartData.isNotEmpty
        ? chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b)
        : 0.0;

    minY = minY > 0 ? minY - 1 : minY;
    maxY = maxY < 10 ? maxY + 1 : maxY;

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
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: true,
                horizontalInterval: (maxY - minY) / 5,
                verticalInterval: 1,
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
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: chartData,
                  isCurved: true,
                  color: color,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                  barWidth: 3,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}