import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'live_tracking_screen.dart';

class AvailableVehiclesScreen extends StatefulWidget {
  final String destination;

  const AvailableVehiclesScreen({Key? key, required this.destination})
      : super(key: key);

  @override
  _AvailableVehiclesScreenState createState() =>
      _AvailableVehiclesScreenState();
}

class _AvailableVehiclesScreenState extends State<AvailableVehiclesScreen> {
  List<Map<String, String>> availableBuses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableBuses();
  }

  void _fetchAvailableBuses() {
    FirebaseDatabase.instance.ref("buses").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      List<Map<String, String>> busesList = [];

      if (data != null) {
        data.forEach((key, value) {
          // Case 1: Top-level bus (has 'destination' key)
          if (value is Map && value.containsKey('destination')) {
            print("Top-level Bus: $key → Destination: ${value['destination']} Status: ${value['status']}");
            if (value['destination']?.trim().toLowerCase() == widget.destination.trim().toLowerCase() &&
                value['status'] == 'online') {
              busesList.add({
                'busId': key.toString(),
                'sacco': value['sacco']?.toString() ?? 'Unknown',
              });
            }
          }
          // Case 2: Nested buses under a sacco
          else if (value is Map) {
            value.forEach((nestedKey, nestedValue) {
              if (nestedValue is Map) {
                print("Nested Bus: $nestedKey (Sacco: $key) → Destination: ${nestedValue['destination']} Status: ${nestedValue['status']}");
                if (nestedValue['destination']?.trim().toLowerCase() == widget.destination.trim().toLowerCase() &&
                    nestedValue['status'] == 'online') {
                  busesList.add({
                    'busId': nestedKey.toString(),
                    'sacco': key.toString(),
                  });
                }
              }
            });
          }
        });
      }

      setState(() {
        availableBuses = busesList;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Vehicles to ${widget.destination}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : availableBuses.isEmpty
              ? Center(child: Text("No available vehicles for ${widget.destination}"))
              : ListView.builder(
                  itemCount: availableBuses.length,
                  itemBuilder: (context, index) {
                    final bus = availableBuses[index];
                    return ListTile(
                      leading: Icon(Icons.directions_bus, color: Colors.blue, size: 40),
                      title: Text("Bus: ${bus['busId']}"),
                      subtitle: Text("Sacco: ${bus['sacco']}"),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LiveTrackingScreen(busId: bus['busId']!),
                            ),
                          );
                        },
                        child: Text("Book Seat"),
                      ),
                    );
                  },
                ),
    );
  }
}
