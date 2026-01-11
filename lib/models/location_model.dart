import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pixel_weather/services/location_service.dart';

class LocationModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  double? _latitude;
  double? _longitude;
  String? _cityName;
  bool _isLoading = false;
  String? _error;

  // Getter'lar
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get cityName => _cityName;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Konumu al ve şehir adını bul
  Future<void> fetchCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Konum izni kontrol et ve konum al
      Position? position = await _locationService.getCurrentLocation();

      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;

        // Enlem-boylam'dan şehir adını bul
        String? city = await _locationService.getAddressFromCoordinates(
          _latitude!,
          _longitude!,
        );

        if (city != null && city.isNotEmpty && city != 'Bilinmiyor') {
          _cityName = city;
        } else {
          _error = 'Şehir adı bulunamadı, varsayılan şehir kullanılıyor';
          _cityName = 'Istanbul'; // Fallback
        }
      }
    } catch (e) {
      _error = e.toString();
      _cityName = 'Istanbul'; // Hata durumunda fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
