import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'live_tracking_screen.dart';

class BookingScreen extends StatefulWidget {
final String busId;
final String sacco;
final String destination;

const BookingScreen({
Key? key,
required this.busId,
required this.sacco,
required this.destination,
}) : super(key: key);

@override
_BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
int availableSeats = 33; // Default seat count
bool isLoading = true;

@override
void initState() {
super.initState();
_fetchAvailableSeats();
}

void _fetchAvailableSeats() {
DatabaseReference seatRef = FirebaseDatabase.instance.ref("buses/${widget.busId}/availableSeats");

seatRef.onValue.listen((event) {
if (event.snapshot.value != null) {
setState(() {
availableSeats = event.snapshot.value as int;
isLoading = false;
});
} else {
setState(() {
availableSeats = 0; // Assume no seats if data is null
isLoading = false;
});
}
});
}

void _bookSeat() async {
DatabaseReference seatRef = FirebaseDatabase.instance.ref("buses/${widget.busId}/availableSeats");

await seatRef.runTransaction((mutableData) {
if (mutableData != null && mutableData > 0) {
return mutableData - 1; // Reduce seats by 1
}
return mutableData;
}).then((transaction) {
if (transaction.committed) {
setState(() {
availableSeats--; // Update UI after successful booking
});

// Navigate to Live Tracking Screen
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => LiveTrackingScreen(busId: widget.busId),
),
);
} else {
// Show error if booking failed
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text("Booking failed. No available seats.")),
);
}
}).catchError((error) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text("Error: ${error.toString()}")),
);
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text("Book Your Seat")),
body: isLoading
? Center(child: CircularProgressIndicator())
: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Text("Bus: ${widget.busId}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
Text("Sacco: ${widget.sacco}", style: TextStyle(fontSize: 18)),
Text("Destination: ${widget.destination}", style: TextStyle(fontSize: 18)),
SizedBox(height: 20),
Text("Available Seats: $availableSeats",
style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
SizedBox(height: 30),
ElevatedButton(
onPressed: availableSeats > 0 ? _bookSeat : null,
child: Text("Confirm Booking"),
style: ElevatedButton.styleFrom(
padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
textStyle: TextStyle(fontSize: 18),
backgroundColor: availableSeats > 0 ? Colors.blue : Colors.grey,
),
),
],
),
),
);
}
}