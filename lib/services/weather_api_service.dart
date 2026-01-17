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
      print('Fetching weather for city: $city');
      final url = '$baseUrl?q=$city&appid=$apiKey&units=metric&lang=tr';
      print('URL: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('İstek zaman aşımına uğradı'),
          );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('API Key geçersiz');
      } else if (response.statusCode == 404) {
        throw Exception('Şehir bulunamadı: $city');
      } else {
        throw Exception(
          'Hava durumu alınamadı (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('Weather API Error: $e');
      throw Exception('Bağlantı hatası: $e');
    }
  }

  Future<Map<String, dynamic>> getForecast(String city) async {
    try {
      print('Fetching forecast for city: $city');
      final url = '$forecastBaseUrl?q=$city&appid=$apiKey&units=metric&lang=tr';
      print('URL: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('İstek zaman aşımına uğradı'),
          );

      print('Forecast Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('API Key geçersiz');
      } else if (response.statusCode == 404) {
        throw Exception('Şehir bulunamadı: $city');
      } else {
        throw Exception(
          'Tahmin alınamadı (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('Forecast API Error: $e');
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
