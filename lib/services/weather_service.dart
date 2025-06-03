import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  static Future<bool> willRainTomorrow() async {
    const double lat = -6.6351;  // Lokasi Bumi Pakuan 2
    const double lon = 106.8166;
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];

    final url =
        'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,current,alerts&units=metric&appid=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List daily = data['daily'];
      if (daily.isNotEmpty) {
        final rainProb = daily[0]['pop']; // Probability of precipitation
        return rainProb > 0.4; // jika > 40% maka kemungkinan hujan
      }
    }
    return false;
  }
}
