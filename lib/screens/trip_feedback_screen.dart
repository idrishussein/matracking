import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripFeedbackScreen extends StatefulWidget {
  final String vehicleName;

  TripFeedbackScreen({required this.vehicleName});

  @override
  _TripFeedbackScreenState createState() => _TripFeedbackScreenState();
}

class _TripFeedbackScreenState extends State<TripFeedbackScreen> {
  int _rating = 0;
  TextEditingController _feedbackController = TextEditingController();

  void _submitFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Thank you for your feedback!")),
    );
    Navigator.pop(context); // Go back to home or history screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text("Trip Feedback", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How was your ride with ${widget.vehicleName}?",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20),
            _buildRatingStars(),
            SizedBox(height: 20),
            Text("Additional Feedback:", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
            SizedBox(height: 10),
            _buildFeedbackInput(),
            SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            Icons.star,
            size: 40,
            color: index < _rating ? Colors.yellow : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
        );
      }),
    );
  }

  Widget _buildFeedbackInput() {
    return TextField(
      controller: _feedbackController,
      maxLines: 4,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Write your feedback...",
        hintStyle: GoogleFonts.poppins(color: Colors.white70),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _rating > 0 ? _submitFeedback : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
        ),
        child: Text("Submit", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
