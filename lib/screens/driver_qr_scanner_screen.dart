import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class DriverQRScannerScreen extends StatefulWidget {
  @override
  _DriverQRScannerScreenState createState() => _DriverQRScannerScreenState();
}

class _DriverQRScannerScreenState extends State<DriverQRScannerScreen> {
  bool isScanning = true;
  String scanResult = "";

  // Handle the QR code once detected
  void _handleQRCodeScanned(String qrCode) {
    setState(() {
      isScanning = false;
      scanResult = qrCode;
    });

    // Simulate a delay before navigating back with the QR Code
    Future.delayed(Duration(seconds: 2), () {
      if (scanResult.isNotEmpty) {
        Navigator.pop(context, qrCode); // Return scanned QR Code
      } else {
        _showError("Invalid QR Code");
      }
    });
  }

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text(
          "Scan Passenger QR",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isScanning ? "Align QR code within the frame" : "Scanned: $scanResult",
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: isScanning
                ? MobileScanner(
                    onDetect: (barcode, args) {
                      if (barcode.rawValue != null) {
                        _handleQRCodeScanned(barcode.rawValue!);
                      }
                    },
                  )
                : Center(
                    child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 100),
                  ),
          ),
          const SizedBox(height: 30),
          if (!isScanning)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isScanning = true;
                  scanResult = "";
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
              ),
              child: Text(
                "Scan Another",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
