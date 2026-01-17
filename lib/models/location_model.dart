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
        debugPrint('Position obtained: $_latitude, $_longitude');

        // Enlem-boylam'dan şehir adını bul
        try {
          String? city = await _locationService.getAddressFromCoordinates(
            _latitude!,
            _longitude!,
          );

          if (city != null && city.isNotEmpty) {
            _cityName = city;
            _error = null;
            debugPrint('City found: $_cityName');
          } else {
            _error = 'Şehir adı alınamadı';
            _cityName = null;
          }
        } catch (addressError) {
          _error = 'Geocoding hatası: $addressError';
          _cityName = null;
          debugPrint('Address error: $addressError');
        }
      } else {
        _error = 'Konum bilgisi alınamadı';
        _cityName = null;
      }
    } catch (e) {
      _error = 'Konum hatası: $e';
      _cityName = null;
      debugPrint('Location error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
