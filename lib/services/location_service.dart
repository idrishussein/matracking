import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  static final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref("buses_location");
  static StreamSubscription<Position>? _positionStream;

  // Check and request location permissions
  static Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    return permission != LocationPermission.deniedForever;
  }

  // Get the current location
  static Future<Position?> getCurrentLocation() async {
    bool hasPermission = await checkPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  // Start tracking and sending location to Firebase under the selected bus
  static void startLocationTracking(String busId) async {
    bool hasPermission = await checkPermission();
    if (!hasPermission) {
      print("Location permission denied.");
      return;
    }

    bool locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      print("Location services are disabled. Please enable them.");
      return;
    }

    _positionStream?.cancel(); // Cancel previous stream if any

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Send updates every 10 meters
      ),
    ).listen((Position position) {
      try {
        _dbRef.child(busId).set({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "timestamp": DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print("Error updating location: $e");
      }
    });
  }

  // Stop tracking location
  static void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    print("Location tracking stopped.");
  }
}
