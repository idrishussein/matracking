import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'where_to_screen.dart'; // Next screen

class PassengerAuthScreen extends StatefulWidget {
  @override
  _PassengerAuthScreenState createState() => _PassengerAuthScreenState();
}

class _PassengerAuthScreenState extends State<PassengerAuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15), // Add some spacing on top
              Text(
                "Passenger Login",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              _buildTextField("Email", emailController, Icons.email),
              SizedBox(height: 15),
              _buildTextField("Password", passwordController, Icons.lock, obscureText: true),
              SizedBox(height: 25),
              _buildLoginButton(),
              SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  // Implement forgot password logic
                },
                child: Text(
                  "Forgot Password?",
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ),
              SizedBox(height: 20),
              _buildGoogleSignInButton(),
              SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  // Navigate to Sign Up screen (if needed)
                },
                child: Text(
                  "Don't have an account? Sign up",
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ),
              SizedBox(height: 20), // Add bottom spacing to avoid clipping
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        // Validate inputs here before navigating
        if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WhereToScreen()),
          );
        } else {
          // Show error message if fields are empty
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please fill in both fields.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
        textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text("Login"),
    );
  }

  Widget _buildGoogleSignInButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Implement Google sign-in logic
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[900],
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(Icons.login),
      label: Text("Sign in with Google", style: GoogleFonts.poppins(fontSize: 16)),
    );
  }
}
