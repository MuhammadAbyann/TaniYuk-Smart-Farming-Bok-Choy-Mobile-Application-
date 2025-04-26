class SensorData {
  final DateTime time;
  final double ph;
  final double kelembabanTanah;
  final double kelembabanUdara;
  final double suhu;
  final double cahaya;

  SensorData({
    required this.time,
    required this.ph,
    required this.kelembabanTanah,
    required this.kelembabanUdara,
    required this.suhu,
    required this.cahaya,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      time: DateTime.parse(json['_time']),
      ph: (json['ph'] ?? 0).toDouble(),
      kelembabanTanah: (json['kelembaban_tanah'] ?? 0).toDouble(),
      kelembabanUdara: (json['kelembaban_udara'] ?? 0).toDouble(),
      suhu: (json['suhu'] ?? 0).toDouble(),
      cahaya: (json['cahaya'] ?? 0).toDouble(),
    );
  }
}
