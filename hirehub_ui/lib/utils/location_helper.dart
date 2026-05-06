import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class LocationHelper {
  static Future<String> getExactLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return await _fallbackIPLocation();
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return await _fallbackIPLocation();
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return await _fallbackIPLocation();
      } 

      // Get precise position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 10));

      // On Web, the geocoding package isn't fully supported without extra config, 
      // so we use a free reverse geocoding HTTP API for coordinates.
      if (kIsWeb) {
        try {
          final dio = Dio();
          final response = await dio.get(
              'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${position.latitude}&longitude=${position.longitude}&localityLanguage=en');
          
          if (response.statusCode == 200) {
            final data = response.data;
            String locality = data['locality'] ?? '';
            String principalSubdivision = data['principalSubdivision'] ?? '';
            
            if (locality.isNotEmpty) {
              return principalSubdivision.isNotEmpty ? '$locality, $principalSubdivision' : locality;
            }
          }
        } catch (e) {
          debugPrint('Web reverse geocode error: $e');
        }
      } else {
        // Native Mobile Reverse Geocoding
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String location = '';
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            location = place.subLocality!;
          } else if (place.locality != null && place.locality!.isNotEmpty) {
            location = place.locality!;
          }

          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            if (location.isNotEmpty) {
              location += ', ${place.administrativeArea}';
            } else {
              location = place.administrativeArea!;
            }
          }

          return location.isNotEmpty ? location : 'Unknown Location';
        }
      }

      return await _fallbackIPLocation();
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      return await _fallbackIPLocation();
    }
  }

  // Fallback to IP-based location if GPS fails (e.g. on emulator without mock location)
  static Future<String> _fallbackIPLocation() async {
    try {
      final dio = Dio();
      final response = await dio.get('http://ip-api.com/json/');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data;
        return "${data['city']}, ${data['country']}";
      }
      return 'Location Unavailable';
    } catch (e) {
      return 'Location Unavailable';
    }
  }
}
