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

      if (newData.isNotEmpty) {
        // Asumsi SensorData ada properti DateTime timestamp
        newData.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // ascending

        setState(() {
          _sensorData = newData.length > 10 ? newData.sublist(newData.length - 10) : newData;
        });
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }

  bool listEquals(List<SensorData> a, List<SensorData> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Widget _buildCombinedChart() {
  List<double> soilMoistureValues = _sensorData.map((d) {
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

  final chartDataCahaya = _sensorData
      .asMap()
      .entries
      .map((entry) => FlSpot(entry.key.toDouble(), entry.value.lux ?? 0.0))
      .toList();

  final chartDataKelembapanTanah = soilMoistureValues
      .asMap()
      .entries
      .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
      .toList();

  final chartDataPhTanah = _sensorData
      .asMap()
      .entries
      .map((entry) => FlSpot(entry.key.toDouble(), entry.value.phSensor ?? 0.0))
      .toList();

  final chartDataPhNano = _sensorData
      .asMap()
      .entries
      .map((entry) => FlSpot(entry.key.toDouble(), entry.value.pHNano ?? 0.0))
      .toList(); // Menambahkan pH Nano ke grafik

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
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (_sensorData.length > 0 ? _sensorData.length - 1 : 9).toDouble(),
        minY: 0,
        maxY: 1500, // Sesuaikan maxY sesuai data cahaya atau buat dinamis
        lineBarsData: [
          LineChartBarData(
            spots: chartDataCahaya,
            isCurved: true,
            color: Colors.yellow,
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: chartDataKelembapanTanah,
            isCurved: true,
            color: Colors.blue,
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: chartDataPhTanah,
            isCurved: true,
            color: Colors.green,
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: chartDataPhNano, // Tambahkan bar untuk pH Nano
            isCurved: true,
            color: Colors.red, // Ubah warna sesuai keinginan
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildBasicMonitoring(SensorData? latestData) {
    double? kelembapanTanah;
    if (latestData != null) {
      List<double> values = [
        latestData.nanoMoisture1 ?? 0,
        latestData.nanoMoisture2 ?? 0,
        latestData.nanoMoisture3 ?? 0,
        latestData.soilMoisture1 ?? 0,
        latestData.soilMoisture2 ?? 0,
      ];
      final count = values.where((v) => v > 0).length;
      kelembapanTanah = count == 0 ? null : values.reduce((a, b) => a + b) / count;
    }

    final List<Map<String, dynamic>> basicMonitoringData = [
      {
        'icon': Icons.water_drop,
        'label': 'Kelembapan',
        'value': kelembapanTanah != null ? '${kelembapanTanah.toStringAsFixed(1)}%' : '--%',
        'color': (kelembapanTanah != null && kelembapanTanah < 50)
            ? const Color.fromARGB(255, 139, 0, 0)
            : Colors.blue[200],
      },
      {
        'icon': Icons.science,
        'label': 'pH Sensor',
        'value': latestData != null && latestData.phSensor != null ? '${latestData.phSensor!.toStringAsFixed(1)}' : '--',
        'color': (latestData != null && (latestData.phSensor != null && (latestData.phSensor! < 5.5 || latestData.phSensor! > 7)))
            ? const Color.fromARGB(255, 139, 0, 0)
            : Colors.green[200],
      },
      {
        'icon': Icons.science,
        'label': 'pH Nano',
        'value': latestData != null && latestData.pHNano != null ? '${latestData.pHNano!.toStringAsFixed(1)}' : '--',
        'color': (latestData != null && (latestData.pHNano != null && (latestData.pHNano! < 5.5 || latestData.pHNano! > 7)))
            ? const Color.fromARGB(255, 139, 0, 0)
            : Colors.purpleAccent[200],
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
      height: 110,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back),
                  Column(
                    children: const [
                      Text(
                        "Pakcoy Fields",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Ditanam 1 April 2025",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Color(0xFF184C45),
                    child: Icon(Icons.person, color: Colors.white),
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
                "Garis Kuning: Cahaya | Garis Biru: Kelembapan | Garis Merah: pH Nano | Garis Hijau : pH Sensor",
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
