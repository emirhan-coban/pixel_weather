import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  // Konum izni kontrol et
  Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Şu anki konumu al (enlem, boylam)
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkPermission();
      if (!hasPermission) {
        throw Exception('Konum izni verilmedi');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      throw Exception('Konum alınamadı: $e');
    }
  }

  // Enlem ve boylam'dan şehir adını bul (geocoding)
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Şehir adını veya bölge adını döndür
        String? city =
            place.locality ??
            place.administrativeArea ??
            place.country ??
            'Bilinmiyor';
        return city;
      }
      // Eğer placemarks boşsa, başka bir fallback yöntemi try
      return _getAddressFromOpenWeather(latitude, longitude);
    } catch (e) {
      // Hata durumunda fallback
      try {
        return await _getAddressFromOpenWeather(latitude, longitude);
      } catch (_) {
        throw Exception('Adres alınamadı');
      }
    }
  }

  // Fallback: OpenWeatherMap Reverse Geocoding API
  Future<String> _getAddressFromOpenWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final String apiKey = 'senin_api_key_buraya'; // API key ekle
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/geo/1.0/reverse?lat=$latitude&lon=$longitude&limit=1&appid=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty) {
          return data[0]['name'] ?? 'Bilinmiyor';
        }
      }
      return 'Bilinmiyor';
    } catch (e) {
      return 'Bilinmiyor';
    }
  }
}
