import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:matracking/services/location_service.dart';

class DriverDashboardScreen extends StatefulWidget {
  @override
  _DriverDashboardScreenState createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = false;
  String? _selectedSacco, _selectedBus, _selectedDestination;
  String _estimatedTimeOfArrival = "Calculating...";
  DatabaseReference? _busRef;
  GeolocatorPlatform geolocator = GeolocatorPlatform.instance;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void dispose() {
    _goOffline();
    super.dispose();
  }

  void _goOnline() async {
    if (_selectedSacco == null || _selectedBus == null || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a Sacco, bus, and destination.')),
      );
      return;
    }

    setState(() => _isOnline = true);

    Position position = await _getCurrentLocation();
    _busRef = FirebaseDatabase.instance.ref("buses/$_selectedSacco/$_selectedBus");

    await _busRef!.set({
      'status': 'online',
      'destination': _selectedDestination,
      'sacco': _selectedSacco,
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      }
    });

    _startLocationUpdates();
  }

  void _goOffline() {
    if (_busRef != null) {
      _busRef!.update({'status': 'offline'}).catchError((error) {
        print("Error updating status: $error");
      });
    }

    _positionSubscription?.cancel();
    setState(() => _isOnline = false);
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return Future.error("Location services disabled");
    }

    LocationPermission permission = await geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission denied. Enable it from settings.')),
      );
      return Future.error("Location permission denied");
    }

    return await geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  void _startLocationUpdates() {
    _positionSubscription = geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (_isOnline && _busRef != null) {
        _busRef!.update({
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        });

        setState(() {
          _estimatedTimeOfArrival = _calculateETA(position.latitude, position.longitude);
        });
      }
    });
  }

  String _calculateETA(double lat, double lng) {
    return "${(lat + lng) % 10 + 5} min";
  }

  // Status card with improved alignment
  Widget _buildStatusCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Status: Online",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  // Improved dropdown using DropdownButtonFormField
  Widget _buildDropdown(String title, List<String> options, Function(String) onChanged) {
    String? currentValue;
    if (title == "Choose Sacco") {
      currentValue = _selectedSacco;
    } else if (title == "Select Bus") {
      currentValue = _selectedBus;
    } else if (title == "Select Destination") {
      currentValue = _selectedDestination;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          hint: Text("Select", style: GoogleFonts.poppins(color: Colors.black)),
          value: currentValue,
          items: options.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(fontSize: 16)),
            );
          }).toList(),
          onChanged: (value) {
            onChanged(value!);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Center(
          child: Text(
            "Driver Dashboard",
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            // Centering content
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDropdown("Choose Sacco", ["Super Metro", "KMO", "Ongata Line", "KBS", "City Hoppa"], (val) {
                setState(() => _selectedSacco = val);
              }),
              SizedBox(height: 20),
              _buildDropdown("Select Bus", ["Bus 101", "Bus 202", "Bus 303", "Bus 404"], (val) {
                setState(() => _selectedBus = val);
              }),
              SizedBox(height: 20),
              _buildDropdown("Select Destination", [
                "Thika Road", "Jogoo Road", "Mombasa Road", "Ngong Road",
                "Donholm", "Buruburu", "Kasarani", "Lang'ata", "South B", "South C", "Umoja",
                "Ruiru", "Kikuyu", "Kitengela", "Ngong", "Athi River", "Limuru", "Thika"
              ], (val) {
                setState(() => _selectedDestination = val);
              }),
              SizedBox(height: 30),
              if (!_isOnline)
                ElevatedButton(
                  onPressed: _goOnline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    "Go Online",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              if (_isOnline) ...[
                _buildStatusCard(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _goOffline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    "Go Offline",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
