import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class PassengerQRScreen extends StatelessWidget {
  final String bookingId;
  final String passengerName;
  final String busId;

  const PassengerQRScreen({
    Key? key,
    required this.bookingId,
    required this.passengerName,
    required this.busId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String qrData = "$busId|$bookingId|$passengerName";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Boarding QR Code"),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 20),
            Text(
              "Show this QR code to the driver to board",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
