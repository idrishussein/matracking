import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';  // To format dates

class HistoryProfileScreen extends StatefulWidget {
  @override
  _HistoryProfileScreenState createState() => _HistoryProfileScreenState();
}

class _HistoryProfileScreenState extends State<HistoryProfileScreen> {
  List<Map<String, String>> tripHistory = [
    {"vehicle": "Nganya Express", "date": "2025-03-25", "fare": "Ksh 150"},
    {"vehicle": "City Shuttle", "date": "2025-03-24", "fare": "Ksh 100"},
    {"vehicle": "Eastlands Mat", "date": "2025-03-22", "fare": "Ksh 120"},
  ];

  // Function to format the date
  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('d MMM yyyy').format(parsedDate);  // Formats as "25 Mar 2025"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text("History & Profile", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            SizedBox(height: 20),
            Text("Trip History", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 10),
            _buildTripHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Colors.blue[900]),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("John Doe", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 5),
              Text("johndoe@gmail.com", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
              SizedBox(height: 5),
              _buildEditProfileButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Text("Edit Profile", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTripHistory() {
    return Expanded(
      child: ListView.builder(
        itemCount: tripHistory.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white24,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(tripHistory[index]["vehicle"]!, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(formatDate(tripHistory[index]["date"]!), style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
              trailing: Text(tripHistory[index]["fare"]!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
            ),
          );
        },
      ),
    );
  }
}
