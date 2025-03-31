import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';

class EndJourneyScreen extends StatelessWidget {
  final String bus;

  const EndJourneyScreen({Key? key, required this.bus}) : super(key: key);

  // Function to show confirmation dialog before ending the journey
  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("End Journey", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to end the journey and remove the bus data?", style: GoogleFonts.poppins()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel", style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                _endTrip(context);
                Navigator.pop(context); // Close the dialog after confirming
              },
              child: Text("Yes, End Trip", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _endTrip(BuildContext context) {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref("buses");

    // Remove bus data from Firebase
    dbRef.child(bus).remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Journey ended successfully!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to driver home screen
      Navigator.popUntil(context, (route) => route.isFirst);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error ending journey!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      appBar: AppBar(
        title: Text("End Journey", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.done_all, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text("Journey Completed!", style: GoogleFonts.poppins(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Thank you for using Matracking", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70)),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _showConfirmationDialog(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                child: Text("End Trip", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
