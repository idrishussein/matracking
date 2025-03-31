import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'available_vehicles_screen.dart'; // Next screen

class WhereToScreen extends StatelessWidget {
  final List<String> mainRoads = ["Thika Road", "Mombasa Road", "Ngong Road", "Lang'ata Road"];
  final List<String> estates = ["Donholm", "South B", "Ruiru", "Kasarani", "Kikuyu", "Umoja", "Buru Buru", "Tassia", "Lavington"];
  final List<String> towns = ["Kitengela", "Athi River", "Limuru", "Juja"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text("Where to?", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategory(context, "Main Roads", mainRoads),
              SizedBox(height: 20),
              _buildCategory(context, "Estates", estates),
              SizedBox(height: 20),
              _buildCategory(context, "Towns/Outskirts", towns),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, List<String> destinations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        Column(
          children: destinations
              .map((destination) => _buildDestinationTile(context, destination))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDestinationTile(BuildContext context, String destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AvailableVehiclesScreen(destination: destination)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          destination,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]),
        ),
      ),
    );
  }
}
