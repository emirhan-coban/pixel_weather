import 'package:flutter/material.dart';

class WeatherBackground {
  static const Set<String> _rainyKeywords = {
    'rain',
    'rainy',
    'drizzle',
    'thunderstorm',
  };

  static bool shouldShowRainAnimation(String? weatherMain) {
    if (weatherMain == null) return false;
    return _rainyKeywords.contains(weatherMain.toLowerCase());
  }

  static const Set<String> _snowKeywords = {'snow', 'snowy'};

  static bool shouldShowSnowAnimation(String? weatherMain) {
    if (weatherMain == null) return false;
    return _snowKeywords.contains(weatherMain.toLowerCase());
  }

  // Sunrise/Sunset'e göre gece saati mi kontrol et
  static bool isNightTimeBasedOnLocation(int? sunrise, int? sunset) {
    if (sunrise == null || sunset == null) {
      // Fallback: Cihazın saatine göre kontrol et
      final hour = DateTime.now().hour;
      return hour >= 18 || hour < 6;
    }

    // Mevcut zamanı Unix timestamp'e çevir
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Eğer mevcut saat sunset'ten sonra veya sunrise'dan önce ise gece
    return currentTime > sunset || currentTime < sunrise;
  }

  // Hava durumuna göre background resmi döndür
  static String getBackgroundImage(
    String? weatherMain,
    int? sunrise,
    int? sunset,
  ) {
    // Gece saatiyse night background döndür
    if (isNightTimeBasedOnLocation(sunrise, sunset)) {
      return 'assets/backgrounds/night.png';
    }

    if (weatherMain == null) return 'assets/backgrounds/sunny.png';

    switch (weatherMain.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return 'assets/backgrounds/sunny.png';
      case 'clouds':
      case 'cloudy':
        return 'assets/backgrounds/sunny.png';
      case 'rain':
      case 'rainy':
      case 'drizzle':
        return 'assets/backgrounds/rainy.png';
      case 'thunderstorm':
        return 'assets/backgrounds/rainy.png';
      case 'snow':
      case 'snowy':
        return 'assets/backgrounds/snowy.png';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return 'assets/backgrounds/rainy.png';
      default:
        return 'assets/backgrounds/sunny.png';
    }
  }

  // Hava durumuna göre background widget
  static Widget getBackgroundWidget(
    String? weatherMain,
    int? sunrise,
    int? sunset,
  ) {
    final imagePath = getBackgroundImage(weatherMain, sunrise, sunset);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
    );
  }
}
