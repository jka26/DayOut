import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Single access point for all environment variables.
/// Keys are read from the .env file loaded at app startup.
class Env {
  Env._();

  static String get openWeatherMapKey =>
      dotenv.env['OPENWEATHERMAP_KEY'] ?? '';

  static String get foursquareKey =>
      dotenv.env['FOURSQUARE_KEY'] ?? '';

  static String get googlePlacesKey =>
      dotenv.env['GOOGLE_PLACES_KEY'] ?? '';

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? '';

  /// True when real weather data can be fetched.
  static bool get hasWeather => openWeatherMapKey.isNotEmpty;

  /// True when real place data can be fetched.
  static bool get hasPlaces => foursquareKey.isNotEmpty;

  /// True when Google Maps features are available.
  static bool get hasMaps => googlePlacesKey.isNotEmpty;
}
