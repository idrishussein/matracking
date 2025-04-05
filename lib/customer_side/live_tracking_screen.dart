import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:matracking/services/location_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String busId;

  LiveTrackingScreen({required this.busId});

  @override
  _LiveTrackingScreenState createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  late MapController mapController;
  late DatabaseReference busLocationRef;
  Position? currentBusLocation;
  final LatLng defaultCenter = LatLng(1.2921, 36.8219); // Nairobi CBD

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    busLocationRef = FirebaseDatabase.instance.ref("buses/${widget.busId}/location");

    LocationService.initialize(widget.busId);

    LocationService.startLocationTracking(widget.busId, (Position position) {
      setState(() {
        currentBusLocation = position;
      });
      mapController.move(LatLng(position.latitude, position.longitude), 14.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Bus Tracking"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: currentBusLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(currentBusLocation!.latitude, currentBusLocation!.longitude),
                initialZoom: 14.0,
              ),
              children: [
                // Prettier tile layer (CartoDB Dark Matter or others)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.matracking',
                ),

                // Bus marker using your custom icon
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(currentBusLocation!.latitude, currentBusLocation!.longitude),
                      width: 50.0,
                      height: 50.0,
                      child: Image.asset(
                        'assets/bus_marker.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    busLocationRef.onValue.drain(); // Proper cleanup
    super.dispose();
  }
}
