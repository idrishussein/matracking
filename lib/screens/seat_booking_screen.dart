import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'live_tracking_screen.dart';
import 'passenger_qr_screen.dart';  // Import QR screen

class SeatBookingScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const SeatBookingScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  _SeatBookingScreenState createState() => _SeatBookingScreenState();
}

class _SeatBookingScreenState extends State<SeatBookingScreen> {
  int? selectedSeat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text(
          "Seat Booking",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vehicle: ${widget.vehicle["name"]}",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "Fare: Ksh ${widget.vehicle["fare"]}",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Text(
              "Select a Seat:",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildSeatGrid(),
            const SizedBox(height: 20),
            _buildConfirmBookingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: widget.vehicle["seats"],
      itemBuilder: (context, index) {
        bool isSelected = selectedSeat == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedSeat = index;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.greenAccent : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "Seat ${index + 1}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.blue[900],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmBookingButton() {
    return ElevatedButton(
      onPressed: selectedSeat != null
          ? () {
              // Generate booking details
              String bookingId = "BK${DateTime.now().millisecondsSinceEpoch}";
              String passengerName = "John Doe"; // Replace with actual user name
              String busId = widget.vehicle["id"]; // Use actual bus ID

              // Navigate to QR screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PassengerQRScreen(
                    bookingId: bookingId,
                    passengerName: passengerName,
                    busId: busId,
                  ),
                ),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text("Confirm Booking"),
    );
  }
}
