import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class WeatherServices {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';

  final String apiKey;

  WeatherServices(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  Future<String> getCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // Kullanıcı kalıcı olarak izni reddettiğinde yapılacaklar.
        return "Location permissions are permanently denied.";
      }

      // Mevcut konumu al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Konumu placemark nesnesine dönüştür
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? city = placemarks.isNotEmpty ? placemarks[0].locality : null;

      return city ?? "Unknown";
    } catch (e) {
      return "Failed to get current city: $e";
    }
  }
}
