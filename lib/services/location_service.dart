import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationService {
  static DatabaseReference? _busLocationRef;
  static StreamSubscription<Position>? _locationSubscription;

  // Initialize Firebase reference for a given bus ID
  static void initialize(String busId) {
    _busLocationRef = FirebaseDatabase.instance.ref("buses/$busId/location");
  }

  // Check for location permissions
  static Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  // Start tracking location and update Firebase; call onUpdate for UI updates.
  static void startLocationTracking(String busId, Function(Position) onUpdate) async {
    if (_busLocationRef == null) {
      // Initialize bus location reference if not already done
      initialize(busId);
    }

    // Ensure only one listener is active at a time
    _locationSubscription?.cancel();

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((Position position) {
      if (_busLocationRef != null) {
        _busLocationRef!.set({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
      onUpdate(position);
    });
  }

  // Stop tracking location
  static void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }
}
