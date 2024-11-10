import 'package:flutter/material.dart';
import 'package:hopehub/constants.dart';
import 'package:hopehub/screens/overview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/main_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final String email;
  LoginScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email; // Pre-fill email field
  }

  Future<void> saveAuthToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  Future<void> saveIsLawyer(bool isLawyer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_lawyer', isLawyer);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/users/login/'), // Backend login endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String accessToken = responseData['access'];
        final bool isLawyer = responseData['is_lawyer'];

        await saveAuthToken(accessToken);
        await saveEmail(email);
        await saveIsLawyer(isLawyer);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
              (route) => false,
        );
      } else {
        final responseData = jsonDecode(response.body);
        _showError(responseData['error'] ?? 'Login failed. Please try again.');
      }
    } catch (e) {
      _showError('An error occurred. Please try again later.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        backgroundColor: Color(0xFFF5F5F5),
      ),
      backgroundColor: Color(0xFFF5F5F5), // Light background color
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(
                  Icons.change_history, // Replace with your logo or image
                  size: 80,
                  color: Colors.blue, // Blue logo color
                ),
                SizedBox(height: 20),
                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Black text for better readability
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Email input
                TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // White input field background
                    hintText: 'example@gmail.com',
                    hintStyle: TextStyle(color: Colors.grey[500]), // Light grey hint text
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Password input
                TextField(
                  controller: passwordController,
                  style: TextStyle(color: Colors.black),
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // White input field background
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey[500]), // Light grey hint text
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.blue, // Blue text for Forgot Password
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue button
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Login",
                    style: TextStyle(color: Colors.white), // White text
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "or",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600], // Grey text for divider
                  ),
                ),
                SizedBox(height: 20),
                // Login with Facebook button
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.facebook, color: Colors.white),
                  label: Text("Login with Facebook", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B5998), // Facebook blue
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Sign in with Apple button
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.apple, color: Colors.white),
                  label: Text("Sign in with Apple", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Black button
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Join Now button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(email: emailController.text),
                        ),
                      );
                    },
                    child: Text(
                      "Join Now",
                      style: TextStyle(
                        color: Colors.blue, // Blue text for Join Now
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
