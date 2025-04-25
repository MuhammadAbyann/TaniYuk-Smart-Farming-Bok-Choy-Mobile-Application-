import 'package:flutter/material.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              MonitoringSection(
                title: 'Kelembapan',
                radioOptions: ['Tinggi', 'Sedang', 'Rendah'],
              ),
              SizedBox(height: 20),
              MonitoringSection(
                title: 'pH Tanah',
                radioOptions: ['Lembab', 'Sedang', 'Kurang'],
              ),
              SizedBox(height: 20),
              MonitoringSection(
                title: 'Cahaya',
                radioOptions: ['Terang', 'Cukup', 'Redup'],
              ),
              SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }
}

class MonitoringSection extends StatefulWidget {
  final String title;
  final List<String> radioOptions;

  const MonitoringSection({
    super.key,
    required this.title,
    required this.radioOptions,
  });

  @override
  State<MonitoringSection> createState() => _MonitoringSectionState();
}

class _MonitoringSectionState extends State<MonitoringSection> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigasi ke halaman detail
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Klik ${widget.title}")));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kotak monitoring
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF184C45),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              "Monitoring",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Radio button status
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 10,
            children:
                widget.radioOptions.map((option) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: option,
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value;
                          });
                        },
                      ),
                      Text(option),
                    ],
                  );
                }).toList(),
          ),
          const SizedBox(height: 8),

          // Tombol kecil di bawah
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  height: 30,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 30,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
