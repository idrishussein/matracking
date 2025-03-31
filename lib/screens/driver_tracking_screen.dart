import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverTrackingScreen extends StatefulWidget {
  final String sacco;
  final String bus;

  const DriverTrackingScreen({Key? key, required this.sacco, required this.bus}) : super(key: key);

  @override
  _DriverTrackingScreenState createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  bool isTracking = true;
  DatabaseReference? busLocationRef;
  DatabaseReference? busStatusRef;
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    busStatusRef = FirebaseDatabase.instance.ref("buses/${widget.sacco}/${widget.bus}/status");
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location permission denied')));
        setState(() => hasPermission = false);
        return;
      }
    }
    setState(() => hasPermission = true);
    _startTracking();
  }

  Future<void> _startTracking() async {
    if (!hasPermission) return;

    busLocationRef = FirebaseDatabase.instance.ref("buses/${widget.sacco}/${widget.bus}/location");

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Minimum distance in meters before updates
        timeLimit: Duration(seconds: 10), // Interval between updates
      ),
    ).listen((Position position) {
      if (isTracking) {
        busLocationRef!.set({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }

  void _setBusStatus(String status) {
    busStatusRef!.set(status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bus status updated: $status"), duration: Duration(seconds: 2)),
    );
  }

  void _stopTracking() {
    setState(() => isTracking = false);
    busLocationRef!.remove(); // Remove location from Firebase
    busStatusRef!.remove(); // Clear bus status
    Navigator.pop(context); // Go back to Driver Dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      appBar: AppBar(
        title: Text("Driver Tracking", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bus, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text("Tracking Live...", style: GoogleFonts.poppins(fontSize: 22, color: Colors.white)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _setBusStatus("Arrived"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Mark as Arrived 🚏", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _setBusStatus("Departed"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text("Mark as Departed 🚌", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _stopTracking,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Stop Tracking", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
