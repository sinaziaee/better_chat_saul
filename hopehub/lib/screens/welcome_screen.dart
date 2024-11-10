import 'package:flutter/material.dart';
import 'package:hopehub/constants.dart';
import 'package:hopehub/screens/signup_screen.dart';
import 'package:hopehub/screens/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WelcomeScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  Future<void> _checkEmail(BuildContext context, String email) async {
    if (email.isEmpty) {
      _showError(context, 'Email is required!');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/users/check-email/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['exists'] == true) {
          // Navigate to Login Screen if email exists
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen(email: email)),
          );
        } else {
          // Navigate to Signup Screen if email doesn't exist
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignupScreen(email: email)),
          );
        }
      } else {
        _showError(context, 'Failed to check email. Please try again.');
      }
    } catch (e) {
      _showError(context, 'An error occurred. Please check your connection.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              final enteredEmail = emailController.text.trim();
              _checkEmail(context, enteredEmail);
            },
            child: Text(
              "Login",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.change_history,
                  size: 80,
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                Text(
                  "Let's Go!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Sign up with email or Facebook",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Email Address',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final enteredEmail = emailController.text.trim();
                    _checkEmail(context, enteredEmail);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Get Started",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
