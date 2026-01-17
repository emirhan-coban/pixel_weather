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
      print('Getting address for: $latitude, $longitude');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      print('Placemarks found: ${placemarks.length}');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        print(
          'Place info - locality: ${place.locality}, adminArea: ${place.administrativeArea}, country: ${place.country}',
        );

        // Boş olmayan ilk değeri döndür
        String? city = (place.locality?.isNotEmpty == true)
            ? place.locality
            : (place.administrativeArea?.isNotEmpty == true)
            ? place.administrativeArea
            : place.country;

        if (city != null && city.isNotEmpty) {
          print('Returning city: $city');
          return city;
        }
      }

      throw Exception('Şehir adı bulunamadı');
    } catch (e) {
      print('Geocoding error: $e');
      throw Exception('Adres alınamadı: $e');
    }
  }
}
