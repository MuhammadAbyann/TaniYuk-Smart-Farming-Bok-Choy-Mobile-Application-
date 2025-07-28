class SensorData {
  final DateTime timestamp;
  final DateTime time;
  final Bedeng1Data bedeng1;
  final Bedeng2Data bedeng2;
  final double? humidity;
  final double? temperature;
  final double? lux;
  final double? flowRate;

  SensorData({
    required this.timestamp,
    required this.time,
    required this.bedeng1,
    required this.bedeng2,
    this.humidity,
    this.temperature,
    this.lux,
    this.flowRate,
  });

  double get averageSoilMoisture {
    final moistures = [
      ...bedeng1.soilMoistures,
      ...bedeng2.soilMoistures,
    ].where((v) => v != null).cast<double>();
    if (moistures.isEmpty) return 0.0;
    return moistures.reduce((a, b) => a + b) / moistures.length;
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    final timestamp = DateTime.parse(json['_time'] ?? json['timestamp']);
    return SensorData(
      timestamp: timestamp,
      time: timestamp,
      bedeng1: Bedeng1Data(
        phSensor: (json['pH_sensor'] as num?)?.toDouble(),
        soilMoisture1: (json['soil_moisture_1'] as num?)?.toDouble(),
        soilMoisture2: (json['soil_moisture_2'] as num?)?.toDouble(),
      ),
      bedeng2: Bedeng2Data(
        pHNano: (json['pH_nano'] as num?)?.toDouble(),
        nanoMoisture1: (json['nano_moisture_1'] as num?)?.toDouble(),
        nanoMoisture2: (json['nano_moisture_2'] as num?)?.toDouble(),
        nanoMoisture3: (json['nano_moisture_3'] as num?)?.toDouble(),
      ),
      humidity: (json['humidity'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      lux: (json['lux'] as num?)?.toDouble(),
      flowRate: (json['flow_rate'] as num?)?.toDouble(),
    );
  }

  factory SensorData.empty() {
    final now = DateTime.now();
    return SensorData(
      timestamp: now,
      time: now,
      bedeng1: Bedeng1Data(phSensor: 0, soilMoisture1: 0, soilMoisture2: 0),
      bedeng2: Bedeng2Data(pHNano: 0, nanoMoisture1: 0, nanoMoisture2: 0, nanoMoisture3: 0),
      humidity: 0,
      temperature: 0,
      lux: 0,
      flowRate: 0,
    );
  }
}

class Bedeng1Data {
  final double? phSensor;
  final double? soilMoisture1;
  final double? soilMoisture2;

  Bedeng1Data({
    this.phSensor,
    this.soilMoisture1,
    this.soilMoisture2,
  });

  List<double?> get soilMoistures => [soilMoisture1, soilMoisture2];

  double get averageMoisture {
    final moistures = soilMoistures.where((v) => v != null).cast<double>();
    if (moistures.isEmpty) return 0.0;
    return moistures.reduce((a, b) => a + b) / moistures.length;
  }
}

class Bedeng2Data {
  final double? pHNano;
  final double? nanoMoisture1;
  final double? nanoMoisture2;
  final double? nanoMoisture3;

  Bedeng2Data({
    this.pHNano,
    this.nanoMoisture1,
    this.nanoMoisture2,
    this.nanoMoisture3,
  });

  List<double?> get soilMoistures => [nanoMoisture1, nanoMoisture2, nanoMoisture3];

  double get averageMoisture {
    final moistures = soilMoistures.where((v) => v != null).cast<double>();
    if (moistures.isEmpty) return 0.0;
    return moistures.reduce((a, b) => a + b) / moistures.length;
  }
}
