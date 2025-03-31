import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverSignupScreen extends StatefulWidget {
  @override
  _DriverSignupScreenState createState() => _DriverSignupScreenState();
}

class _DriverSignupScreenState extends State<DriverSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _fullName, _email, _phoneNumber, _vehicleNumber;
  bool _isLoading = false;

  // Submit form function with basic validation and show loading indicator
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true; // Show loading spinner
      });

      // Simulate a delay for form submission (this will be replaced by actual backend logic)
      await Future.delayed(Duration(seconds: 2));

      // After form submission
      setState(() {
        _isLoading = false; // Hide loading spinner
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Driver registered successfully!")),
      );
      Navigator.pop(context); // Go back to the main app
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text("Driver Signup", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Full Name", (value) => _fullName = value),
              _buildTextField("Email", (value) => _email = value),
              _buildPhoneNumberField(),
              _buildTextField("Vehicle Number", (value) => _vehicleNumber = value),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Phone number field with custom validator
  Widget _buildPhoneNumberField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: GoogleFonts.poppins(color: Colors.white),
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: "Phone Number",
          labelStyle: GoogleFonts.poppins(color: Colors.white),
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        onSaved: (value) => _phoneNumber = value,
        validator: (value) {
          // Simple phone number validation
          final pattern = r'^(?:\+254|0)[1-9]\d{8}$'; // Kenyan phone number format
          if (value == null || value.isEmpty) {
            return "Enter phone number";
          } else if (!RegExp(pattern).hasMatch(value)) {
            return "Enter a valid phone number";
          }
          return null;
        },
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField(String label, Function(String?) onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white),
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        onSaved: onSave,
        validator: (value) => value!.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  // Submit button widget
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm, // Disable button if loading
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
      ),
      child: _isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text("Register", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
