class SensorData {
  final DateTime timestamp;
  final DateTime time;
  final double? phSensor;
  final double? pHNano;
  final double? soilMoisture1;  
  final double? soilMoisture2;
  final double? nanoMoisture1;
  final double? nanoMoisture2;
  final double? nanoMoisture3;
  final double? humidity;
  final double? temperature;
  final double? lux;
  final double? flowRate;

  SensorData({
    required this.timestamp,
    required this.time, 
    this.phSensor,
    this.pHNano,
    this.soilMoisture1,
    this.soilMoisture2,
    this.nanoMoisture1,
    this.nanoMoisture2,
    this.nanoMoisture3,
    this.humidity,
    this.temperature,
    this.lux,
    this.flowRate,
  });

  double get averageSoilMoisture {
    final moistures = [
      soilMoisture1,
      soilMoisture2,
      nanoMoisture1,
      nanoMoisture2,
      nanoMoisture3,
    ].where((v) => v != null).cast<double>();
    if (moistures.isEmpty) return 0.0;
    return moistures.reduce((a, b) => a + b) / moistures.length;
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      timestamp: DateTime.parse(json['_time'] ?? json['timestamp']),
      time: DateTime.parse(json['_time']),
      phSensor: json['pH_sensor'] != null ? (json['pH_sensor'] as num).toDouble() : null,
      pHNano: json['pH_nano'] != null ? (json['pH_nano'] as num).toDouble() : null,
      soilMoisture1: json['soil_moisture_1'] != null ? (json['soil_moisture_1'] as num).toDouble() : null,
      soilMoisture2: json['soil_moisture_2'] != null ? (json['soil_moisture_2'] as num).toDouble() : null,
      nanoMoisture1: json['nano_moisture_1'] != null ? (json['nano_moisture_1'] as num).toDouble() : null,
      nanoMoisture2: json['nano_moisture_2'] != null ? (json['nano_moisture_2'] as num).toDouble() : null,
      nanoMoisture3: json['nano_moisture_3'] != null ? (json['nano_moisture_3'] as num).toDouble() : null,
      humidity: json['humidity'] != null ? (json['humidity'] as num).toDouble() : null,
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
      lux: json['lux'] != null ? (json['lux'] as num).toDouble() : null,
      flowRate: json['flow_rate'] != null ? (json['flow_rate'] as num).toDouble() : null,
    );
  }

  factory SensorData.empty() {
    final now = DateTime.now();
    return SensorData(
      timestamp: now,
      time: now,
      phSensor: 0,
      pHNano: 0,
      soilMoisture1: 0,
      soilMoisture2: 0,
      nanoMoisture1: 0,
      nanoMoisture2: 0,
      nanoMoisture3: 0,
      humidity: 0,
      temperature: 0,
      lux: 0,
      flowRate: 0,
    );
  }
}
