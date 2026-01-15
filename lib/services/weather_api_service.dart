import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherApiService {
  final String apiKey =
      '95b4a365f917c067e26eab8c40279ab3'; // openweathermap.org'dan al
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String forecastBaseUrl =
      'https://api.openweathermap.org/data/2.5/forecast';

  Future<Map<String, dynamic>> getWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric&lang=tr'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Hava durumu alınamadı');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  Future<Map<String, dynamic>> getForecast(String city) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$forecastBaseUrl?q=$city&appid=$apiKey&units=metric&lang=tr',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Tahmin alınamadı');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
