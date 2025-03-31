import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'seat_booking_screen.dart';

class AvailableVehiclesScreen extends StatelessWidget {
  final String destination;

  const AvailableVehiclesScreen({Key? key, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text(
          "Available Vehicles",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var vehicles = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              var vehicle = vehicles[index].data() as Map<String, dynamic>;

              return _buildVehicleCard(context, vehicle);
            },
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Map<String, dynamic> vehicle) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(Icons.directions_bus, color: Colors.blue[900], size: 40),
        title: Text(vehicle["bus"], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sacco: ${vehicle["sacco"]}", style: GoogleFonts.poppins(fontSize: 14)),
            Text("ETA to CBD: ${vehicle["eta"] ?? "Calculating..."} mins", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
            if (vehicle["at_cbd"] == true)
              Text("✅ Bus has arrived at CBD!", style: GoogleFonts.poppins(fontSize: 14, color: Colors.redAccent)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SeatBookingScreen(vehicle: vehicle)),
            );
          },
          child: Text("Book Seat", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
