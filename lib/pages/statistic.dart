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
                      showStatusIndicators: false, // No status indicator for Light Intensity
                    ),
                    const SizedBox(height: 20),
                    SensorChart(
                      title: 'Kelembapan Tanah',
                      chartData: _createChartData(soilMoistureValues),
                      value: soilMoistureValues.isNotEmpty ? soilMoistureValues.last : 0.0,
                      indicatorColor: Colors.blue,
                      showStatusIndicators: true, // Show status indicator for Soil Moisture
                      soilMoistureIndicator: _getSoilMoistureIndicator(soilMoistureValues.last),
                    ),
                    const SizedBox(height: 20),
                    SensorChart(
                      title: 'pH Sensor',
                      chartData: _createChartData(
                        lastTenData.map((d) => d.phSensor ?? 0.0).toList(),
                      ),
                      value: latestData?.phSensor ?? 0.0,
                      indicatorColor: Colors.red,
                      showStatusIndicators: true, // Show status indicator for pH
                      phIndicators: _getPHIndicators(latestData?.phSensor ?? 0.0),
                    ),
                    const SizedBox(height: 20),
                    SensorChart(
                      title: 'pH Nano',
                      chartData: _createChartData(
                        lastTenData.map((d) => d.pHNano ?? 0.0).toList(),
                      ),
                      value: latestData?.pHNano ?? 0.0,
                      indicatorColor: Colors.orange,
                      showStatusIndicators: true, // Show status indicator for pH Nano
                      phIndicators: _getPHIndicators(latestData?.pHNano ?? 0.0),
                    ),
                    const SizedBox(height: 20),
                    SensorChart(
                      title: 'Debit Air',
                      chartData: _createChartData(
                        lastTenData.map((d) => d.flowRate ?? 0.0).toList(),
                      ),
                      value: latestData?.flowRate ?? 0.0,
                      indicatorColor: Colors.green,
                      showStatusIndicators: false, // No status indicator for Flow Rate
                    ),
                    const SizedBox(height: 20),
                    SensorChart(
                      title: 'Temperatur',
                      chartData: _createChartData(
                        lastTenData.map((d) => d.temperature ?? 0.0).toList(),
                      ),
                      value: latestData?.temperature ?? 0.0,
                      indicatorColor: Colors.purple,
                      showStatusIndicators: true, // Show status indicator for Temperature
                      temperatureIndicator: _getTemperatureIndicator(latestData?.temperature ?? 0.0),
                    ),
                    const SizedBox(height: 20),
                    SensorChart(
                      title: 'Kelembapan Udara',
                      chartData: _createChartData(
                        lastTenData.map((d) => d.humidity ?? 0.0).toList(),
                      ),
                      value: latestData?.humidity ?? 0.0,
                      indicatorColor: Colors.cyan,
                      showStatusIndicators: true, // Show status indicator for Humidity
                      humidityIndicator: _getHumidityIndicator(latestData?.humidity ?? 0.0),
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

  String _getSoilMoistureIndicator(double soilMoisture) {
    if (soilMoisture > 60) {
      return 'Tinggi';
    } else if (soilMoisture > 30) {
      return 'Sedang';
    } else {
      return 'Rendah';
    }
  }

  Map<String, Color> _getPHIndicators(double phValue) {
    Map<String, Color> phIndicators = {
      'Asam': phValue < 6.0 ? Colors.red : Colors.transparent,
      'Netral': (phValue >= 6.0 && phValue <= 7.0) ? Colors.blue : Colors.transparent,
      'Basa': phValue > 7.0 ? Colors.green : Colors.transparent,
    };
    return phIndicators;
  }

  String _getTemperatureIndicator(double temperature) {
    if (temperature < 18) {
      return 'Dingin';
    } else if (temperature > 30) {
      return 'Panas';
    } else {
      return 'Ideal';
    }
  }

  String _getHumidityIndicator(double humidity) {
    if (humidity < 50) {
      return 'Rendah';
    } else if (humidity > 80) {
      return 'Tinggi';
    } else {
      return 'Sedang';
    }
  }
}

class SensorChart extends StatelessWidget {
  final String title;
  final List<FlSpot> chartData;
  final double value;
  final Color indicatorColor;
  final bool showStatusIndicators;
  final String? soilMoistureIndicator;
  final Map<String, Color>? phIndicators;
  final String? temperatureIndicator;
  final String? humidityIndicator;

  const SensorChart({
    required this.title,
    required this.chartData,
    required this.value,
    required this.indicatorColor,
    required this.showStatusIndicators,
    this.soilMoistureIndicator,
    this.phIndicators,
    this.temperatureIndicator,
    this.humidityIndicator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Menentukan rentang Y yang lebih tepat berdasarkan data yang ada
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
                horizontalInterval: (maxY - minY) / 5, // Adjust horizontal lines
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
                  color: indicatorColor,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                  barWidth: 3,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (showStatusIndicators) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (soilMoistureIndicator != null) ...[
                _buildStatusIndicator(soilMoistureIndicator ?? 'Tinggi', value > 60 ? Colors.green : Colors.transparent),
                const SizedBox(width: 10),
                _buildStatusIndicator('Sedang', value > 30 && value <= 60 ? Colors.yellow : Colors.transparent),
                const SizedBox(width: 10),
                _buildStatusIndicator('Rendah', value <= 30 ? Colors.red : Colors.transparent),
              ],
              if (phIndicators != null) ...[
                _buildStatusIndicator('Asam', phIndicators!['Asam'] ?? Colors.transparent),
                const SizedBox(width: 10),
                _buildStatusIndicator('Netral', phIndicators!['Netral'] ?? Colors.transparent),
                const SizedBox(width: 10),
                _buildStatusIndicator('Basa', phIndicators!['Basa'] ?? Colors.transparent),
              ],
              if (temperatureIndicator != null) ...[
                _buildStatusIndicator('Panas', value > 30 ? Colors.red : Colors.transparent),
                const SizedBox(width: 10),
                _buildStatusIndicator(temperatureIndicator ?? 'Ideal', Colors.blue),
                const SizedBox(width: 10),
                _buildStatusIndicator('Dingin', value < 18 ? Colors.blue : Colors.transparent),
              ],
              if (humidityIndicator != null) ...[
                _buildStatusIndicator('Tinggi', value > 80 ? Colors.green : Colors.transparent),
                const SizedBox(width: 10),
                _buildStatusIndicator(humidityIndicator ?? 'Sedang', Colors.blue),
                const SizedBox(width: 10),
                _buildStatusIndicator('Rendah', value < 50 ? Colors.red : Colors.transparent),
              ],
            ],
          ),
          const SizedBox(height: 8)
        ],
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
