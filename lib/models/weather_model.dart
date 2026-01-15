import 'package:flutter/material.dart';
import 'package:pixel_weather/services/weather_api_service.dart';

class WeatherModel extends ChangeNotifier {
  final WeatherApiService _apiService = WeatherApiService();

  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _forecastData;
  bool _isLoading = true;
  String? _error;

  // Getter'lar - dışarıdan veri almak için
  Map<String, dynamic>? get weatherData => _weatherData;
  Map<String, dynamic>? get forecastData => _forecastData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Sunrise ve Sunset zamanlarını al (Unix timestamp)
  int? get sunrise => _weatherData?['sys']?['sunrise'] as int?;
  int? get sunset => _weatherData?['sys']?['sunset'] as int?;

  // Şehrin hava durumunu çek
  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Dinleyenlere "bak değişti" de
    print('Hava durumu yükleniyor: $city');

    try {
      _weatherData = await _apiService.getWeather(city);
      _forecastData = await _apiService.getForecast(city);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Yine "bak değişti" de
    }
  }
}
