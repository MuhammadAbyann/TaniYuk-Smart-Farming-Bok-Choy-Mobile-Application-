import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FertilizerControlPage extends StatefulWidget {
  const FertilizerControlPage({super.key});

  @override
  State<FertilizerControlPage> createState() => _FertilizerControlPageState();
}

class _FertilizerControlPageState extends State<FertilizerControlPage> {
  bool isOn = false;
  bool isAuto = false;

  Future<void> sendManualCommand(bool turnOn) async {
    final url = Uri.parse("http://192.168.4.1/fertilizing/${turnOn ? 'on' : 'off'}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Manual: ${response.body}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal manual: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim perintah manual')),
      );
    }
  }

  Future<void> sendAutoCommand() async {
    final url = Uri.parse("http://192.168.4.1/fertilizing/auto");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Otomatis: ${response.body}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal auto: ${response.statusCode}')),
        );
      }
    } catch (e) {
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
      isAuto = true;
      isOn = false;
    });
    await sendAutoCommand();
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
            // Gambar atau ikon pemupukan, jika dibutuhkan
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
            // Tombol Manual dan Otomatis
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
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
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
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Text(
                            isAuto ? 'OTOMATIS ON' : 'OTOMATIS OFF',
                            style: const TextStyle(
                              color: Colors.green,
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
