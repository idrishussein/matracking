import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'driver_tracking_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  @override
  _DriverDashboardScreenState createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  String? _selectedSacco;
  String? _selectedBus;
  bool _isOnline = false;
  final List<String> _saccos = ["Super Metro", "Ongata Line", "City Hoppa", "KBS", "Embassava"];
  final Map<String, List<String>> _buses = {
    "Super Metro": ["SM-001", "SM-002", "SM-003"],
    "Ongata Line": ["OL-101", "OL-102"],
    "City Hoppa": ["CH-500", "CH-501"],
    "KBS": ["KBS-201", "KBS-202"],
    "Embassava": ["EM-701", "EM-702"],
  };
  final TextEditingController _etaController = TextEditingController();

  // Function to handle the 'Go Online' action
  void _goOnline() async {
    if (_selectedSacco != null && _selectedBus != null) {
      try {
        // Get current position
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        
        // Update Firestore with bus location
        await FirebaseFirestore.instance.collection('buses').doc(_selectedBus).set({
          'sacco': _selectedSacco,
          'status': 'online',
          'location': {'latitude': position.latitude, 'longitude': position.longitude},
        });

        // Update UI
        setState(() => _isOnline = true);

        // Navigate to the driver tracking screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DriverTrackingScreen(sacco: _selectedSacco!, bus: _selectedBus!),
          ),
        );
      } catch (e) {
        _showError("Unable to get location: $e");
      }
    } else {
      _showError("Please select a Sacco and Bus");
    }
  }

  // Function to handle sending ETA
  void _sendETA() {
    if (_selectedBus != null && _etaController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('buses').doc(_selectedBus).update({
        'eta': _etaController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ETA sent to passengers!")));
    } else {
      _showError("Enter ETA before sending.");
    }
  }

  // Function to show error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      appBar: AppBar(
        title: Text("Driver Dashboard", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView( // Fixes RenderFlex Overflow
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Icon(Icons.directions_bus, size: 100, color: Colors.white)),
              SizedBox(height: 10),
              Center(child: Text("Select Sacco & Bus", style: GoogleFonts.poppins(fontSize: 22, color: Colors.white))),
              SizedBox(height: 20),

              // Select Sacco
              DropdownButtonFormField<String>(
                value: _selectedSacco,
                items: _saccos.map((sacco) {
                  return DropdownMenuItem(value: sacco, child: Text(sacco));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSacco = value;
                    _selectedBus = null; // Reset bus selection when Sacco changes
                  });
                },
                decoration: InputDecoration(
                  labelText: "Select Sacco",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              SizedBox(height: 10),

              // Select Bus
              DropdownButtonFormField<String>(
                value: _selectedBus,
                items: _selectedSacco == null
                    ? [DropdownMenuItem(value: null, child: Text("Select a bus"))]
                    : _buses[_selectedSacco]!.map((bus) {
                        return DropdownMenuItem(value: bus, child: Text(bus));
                      }).toList(),
                onChanged: (value) => setState(() => _selectedBus = value),
                decoration: InputDecoration(
                  labelText: "Select Bus",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              SizedBox(height: 10),

              // Enter ETA
              TextField(
                controller: _etaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter ETA (mins)",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              SizedBox(height: 20),

              // Send ETA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendETA,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: EdgeInsets.symmetric(vertical: 14)),
                  child: Text("Send ETA to Passengers", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                ),
              ),

              SizedBox(height: 10),

              // Go Online Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goOnline,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(vertical: 14)),
                  child: Text("Go Online", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
