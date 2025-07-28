import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartfarmingpakcoy_apps/pages/statistic.dart';
import 'package:smartfarmingpakcoy_apps/pages/profile_page.dart';
import 'package:smartfarmingpakcoy_apps/api/api_client.dart';
import 'package:smartfarmingpakcoy_apps/pages/sensor_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 1;
  String selectedInterval = 'Weekly';

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
      Future<List<SensorData>> fetchFunc;
      switch (selectedInterval) {
        case 'Daily':
          fetchFunc = ApiClient.getDailySensorData();
          break;
        case 'Weekly':
          fetchFunc = ApiClient.getWeeklySensorData();
          break;
        case 'Monthly':
          fetchFunc = ApiClient.getMonthlySensorData();
          break;
        default:
          fetchFunc = ApiClient.getDailySensorData();
      }

      final newData = await fetchFunc;
      newData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      setState(() {
        _sensorData = newData.length > 10 ? newData.sublist(newData.length - 10) : newData;
      });
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }

  Widget _buildCombinedChart() {
    double normalizeLux(double? value) => value != null ? value / 400.0 : 0.0;

    final originalLuxValues = _sensorData.map((e) => e.lux ?? 0.0).toList();

    final chartDataCahaya = _sensorData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), normalizeLux(entry.value.lux)))
        .toList();

    final chartDataKelembapanBedeng1 = _sensorData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.bedeng1.averageMoisture))
        .toList();

    final chartDataKelembapanBedeng2 = _sensorData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.bedeng2.averageMoisture))
        .toList();

    final chartDataPhBedeng1 = _sensorData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.bedeng1.phSensor ?? 0.0))
        .toList();

    final chartDataPhBedeng2 = _sensorData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.bedeng2.pHNano ?? 0.0))
        .toList();

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF184C45),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                final index = spot.spotIndex;
                final color = spot.bar.color ?? Colors.white;
                String label;
                switch (spot.barIndex) {
                  case 0:
                    label = 'Lux: ${originalLuxValues[index].toStringAsFixed(0)}';
                    break;
                  case 1:
                    label = 'Moisture B1: ${_sensorData[index].bedeng1.averageMoisture.toStringAsFixed(1)}%';
                    break;
                  case 2:
                    label = 'Moisture B2: ${_sensorData[index].bedeng2.averageMoisture.toStringAsFixed(1)}%';
                    break;
                  case 3:
                    label = 'pH B1: ${_sensorData[index].bedeng1.phSensor?.toStringAsFixed(2) ?? "--"}';
                    break;
                  case 4:
                    label = 'pH B2: ${_sensorData[index].bedeng2.pHNano?.toStringAsFixed(2) ?? "--"}';
                    break;
                  default:
                    label = '';
                }
                return LineTooltipItem(label, TextStyle(color: color, fontWeight: FontWeight.bold));
              }).toList(),
            ),
          ),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (_sensorData.isNotEmpty ? _sensorData.length - 1 : 9).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(spots: chartDataCahaya, isCurved: true, color: Colors.yellow, dotData: FlDotData(show: true)),
            LineChartBarData(spots: chartDataKelembapanBedeng1, isCurved: true, color: Colors.blue, dotData: FlDotData(show: true)),
            LineChartBarData(spots: chartDataKelembapanBedeng2, isCurved: true, color: Colors.cyan, dotData: FlDotData(show: true)),
            LineChartBarData(spots: chartDataPhBedeng1, isCurved: true, color: Colors.green, dotData: FlDotData(show: true)),
            LineChartBarData(spots: chartDataPhBedeng2, isCurved: true, color: Colors.red, dotData: FlDotData(show: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicMonitoring(SensorData? latestData) {
    double? kelembapan1 = latestData?.bedeng1.averageMoisture;
    double? kelembapan2 = latestData?.bedeng2.averageMoisture;
    double? ph1 = latestData?.bedeng1.phSensor;
    double? ph2 = latestData?.bedeng2.pHNano;


    final List<Map<String, dynamic>> basicMonitoringData = [
    {
      'icon': Icons.water_drop,
      'label': 'Kelembapan 1',
      'value': kelembapan1 != null ? '${kelembapan1.toStringAsFixed(1)}%' : '--%',
      'color': (kelembapan1 != null && kelembapan1 < 50)
          ? const Color.fromARGB(255, 139, 0, 0)
          : Colors.blue[200],
    },
    {
      'icon': Icons.water_drop,
      'label': 'Kelembapan 2',
      'value': kelembapan2 != null ? '${kelembapan2.toStringAsFixed(1)}%' : '--%',
      'color': (kelembapan2 != null && kelembapan2 < 50)
          ? const Color.fromARGB(255, 139, 0, 0)
          : Colors.cyan[200],
    },
    {
      'icon': Icons.science,
      'label': 'pH Bedeng 1',
      'value': ph1 != null ? '${ph1.toStringAsFixed(1)}' : '--',
      'color': (ph1 != null && (ph1 < 5.5 || ph1 > 7))
          ? const Color.fromARGB(255, 139, 0, 0)
          : Colors.green[200],
    },
    {
      'icon': Icons.science,
      'label': 'pH Bedeng 2',
      'value': ph2 != null ? '${ph2.toStringAsFixed(1)}' : '--',
      'color': (ph2 != null && (ph2 < 5.5 || ph2 > 7))
          ? const Color.fromARGB(255, 139, 0, 0)
          : const Color.fromARGB(255, 249, 69, 14),
    },
    {
      'icon': Icons.wb_sunny,
      'label': 'Cahaya',
      'value': latestData != null ? '${latestData.lux?.toStringAsFixed(0) ?? '--'} lux' : '-- lux',
      'color': (latestData != null && latestData.lux != null && latestData.lux! < 800)
          ? Colors.yellow[200]
          : Colors.yellow[200],
    },
  ];
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: basicMonitoringData.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = basicMonitoringData[index];
          return Container(
            width: 120,
            decoration: BoxDecoration(
              color: item['color'],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], size: 24, color: Colors.black87),
                const SizedBox(height: 6),
                Text(item['label'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(item['value'], style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

 Widget _getBody() {
  final latestData = _sensorData.isNotEmpty ? _sensorData.last : null;
  switch (selectedIndex) {
    case 0:
      return const StatisticPage();
    case 2:
      return const ProfilePage();
    default:
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menempatkan "TaniYuk" di tengah atas
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Mengatur "TaniYuk" di tengah
              children: const [
                Text(
                  "TaniYuk",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "MONITORING",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedInterval,
                    dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    underline: const SizedBox(),
                    iconEnabledColor: const Color.fromARGB(255, 0, 0, 0),
                    items: const [
                      DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedInterval = value!;
                        _fetchSensorData();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildCombinedChart(),
            const SizedBox(height: 10),
            const Text(
              "Kuning: Cahaya | Biru: Kelembapan B1 | Cyan: Kelembapan B2 | Hijau: pH B1 | Merah: pH B2",
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            const Text(
              "Basic Monitoring",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildBasicMonitoring(latestData),
          ],
        ),
      );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _getBody()),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF184C45),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.bar_chart,
                color: selectedIndex == 0 ? Colors.grey[300] : Colors.white,
              ),
              onPressed: () => setState(() => selectedIndex = 0),
            ),
            IconButton(
              icon: Icon(
                Icons.home,
                color: selectedIndex == 1 ? Colors.grey[300] : Colors.white,
              ),
              onPressed: () => setState(() => selectedIndex = 1),
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: selectedIndex == 2 ? Colors.grey[300] : Colors.white,
              ),
              onPressed: () => setState(() => selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}