import 'package:geolocator/geolocator.dart';
import '../models/weather.dart';

class LocationService {
  Future<Place> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are turned off.');
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission is blocked. Enable it in system settings.');
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return Place(
      name: 'My location',
      lat: pos.latitude,
      lon: pos.longitude,
      isCurrent: true,
    );
  }
}
