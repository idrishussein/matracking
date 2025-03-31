import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:firebase_database/firebase_database.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String sacco;
  final String bus;

  const LiveTrackingScreen({Key? key, required this.sacco, required this.bus}) : super(key: key);

  @override
  _LiveTrackingScreenState createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  LatLng? busLocation;
  late DatabaseReference busLocationRef;
  late DatabaseReference busStatusRef;
  String? lastStatus; // Store the last known status to avoid duplicate notifications

  @override
  void initState() {
    super.initState();
    _listenToBusLocation();
    _listenToBusStatus();
  }

  void _listenToBusLocation() {
    busLocationRef = FirebaseDatabase.instance.ref("buses/${widget.sacco}/${widget.bus}/location");
    busLocationRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null && data.containsKey("latitude") && data.containsKey("longitude")) {
        setState(() {
          busLocation = LatLng(data["latitude"], data["longitude"]);
        });
      } else {
        print("Error: No location data found");
      }
    }, onError: (error) {
      print("Error: $error");
    });
  }

  void _listenToBusStatus() {
    busStatusRef = FirebaseDatabase.instance.ref("buses/${widget.sacco}/${widget.bus}/status");
    busStatusRef.onValue.listen((event) {
      final String? newStatus = event.snapshot.value as String?;
      if (newStatus != null && newStatus != lastStatus) {
        _showStatusNotification(newStatus);
        lastStatus = newStatus;
      }
    }, onError: (error) {
      print("Error: $error");
    });
  }

  void _showStatusNotification(String status) {
    String message = "";
    IconData icon = Icons.directions_bus;

    if (status == "Arrived") {
      message = "🚌 Your bus has arrived at CBD!";
      icon = Icons.check_circle;
    } else if (status == "Departed") {
      message = "🚏 Your bus has departed from CBD!";
      icon = Icons.departure_board;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(message, style: GoogleFonts.poppins(fontSize: 16))),
          ],
        ),
        backgroundColor: Colors.black87,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text("Live Tracking", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: busLocation == null
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : FlutterMap(
              options: MapOptions(
                initialCenter: busLocation ?? LatLng(1.2921, 36.8219), // Fallback to default location (CBD)
                initialZoom: 15.0,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    setState(() {
                      busLocation = position.center; // Update busLocation if user manually moves the map
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    if (busLocation != null)
                      Marker(
                        width: 40,
                        height: 40,
                        point: busLocation!,
                        child: Icon(
                          Icons.directions_bus,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
