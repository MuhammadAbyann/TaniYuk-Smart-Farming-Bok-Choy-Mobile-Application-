import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WateringControlPage extends StatefulWidget {
  const WateringControlPage({super.key});

  @override
  State<WateringControlPage> createState() => _WateringControlPageState();
}

class _WateringControlPageState extends State<WateringControlPage> {
  bool isOn = false;
  bool isAuto = false;

  @override
  void initState() {
    super.initState();
    _initializeControlState();
  }

  // Mengambil status kontrol penyiraman dari alat ESP32
  Future<void> _initializeControlState() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.4.1/api/watering/state'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          isOn = jsonData['isOn'];   // Status kontrol manual (nyala/mati)
          isAuto = jsonData['isAuto']; // Status kontrol otomatis (nyala/mati)
        });
      } else {
        debugPrint('Gagal mengambil status kontrol: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Gagal mengambil status kontrol: $e');
    }
  }

  // Mengirim perintah manual ke alat (on/off)
  Future<void> sendManualCommand(bool turnOn) async {
    final url = Uri.parse('http://192.168.4.1/watering/${turnOn ? 'on' : 'off'}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Manual: ${response.body}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal manual: ${response.statusCode}')));
      }
      await _initializeControlState();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Mengirim perintah otomatis ke alat
  Future<void> sendAutoCommand() async {
    final url = Uri.parse('http://192.168.4.1/watering/auto');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Otomatis: ${response.body}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal auto: ${response.statusCode}')));
      }
      await _initializeControlState();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Mengubah status kontrol manual
  void toggleManual() {
    setState(() {
      isOn = !isOn;
      isAuto = false;
    });
    sendManualCommand(isOn);
  }

  // Mengubah status kontrol otomatis
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
            const SizedBox(height: 16),
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
