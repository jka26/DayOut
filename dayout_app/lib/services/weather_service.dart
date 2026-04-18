import 'dart:convert';
import 'dart:io';
import '../config/env.dart';

class WeatherData {
  final double tempCelsius;
  final String condition;   // "Clear", "Rain", "Clouds" …
  final String description; // "clear sky", "light rain" …
  final int conditionCode;  // OpenWeatherMap condition code

  const WeatherData({
    required this.tempCelsius,
    required this.condition,
    required this.description,
    required this.conditionCode,
  });

  /// True when outdoor activities are a good idea.
  bool get isOutdoorFriendly =>
      conditionCode >= 800 && tempCelsius >= 18 && tempCelsius <= 37;

  /// One-line summary for the weather banner.
  String get bannerText {
    final temp = tempCelsius.round();
    final desc = description.toLowerCase();
    final rank = isOutdoorFriendly
        ? 'outdoor spots ranked first'
        : 'indoor spots ranked first';
    return '$temp°C and $desc — $rank today';
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    return WeatherData(
      tempCelsius: (main['temp'] as num).toDouble(),
      condition: weather['main'] as String? ?? 'Clear',
      description: weather['description'] as String? ?? 'clear sky',
      conditionCode: weather['id'] as int? ?? 800,
    );
  }
}

class WeatherService {
  // Accra city centre coordinates
  static const _lat = 5.5600;
  static const _lon = -0.2050;

  /// Fetches current weather for Accra.
  /// Returns null if the API key is not set or the request fails.
  static Future<WeatherData?> fetchAccra() async {
    final key = Env.openWeatherMapKey;
    if (key.isEmpty) return null;

    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 7);
      final req = await client.getUrl(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?lat=$_lat&lon=$_lon&appid=$key&units=metric',
      ));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      if (res.statusCode == 200) {
        return WeatherData.fromJson(
          jsonDecode(body) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return null;
  }
}
