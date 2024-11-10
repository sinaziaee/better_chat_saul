import 'package:flutter/material.dart';
import 'package:hopehub/constants.dart';
import 'package:hopehub/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  final String email;
  const SignupScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLawyer = false; // Default value for the switch
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

  Future<void> _signup() async {
    final String email = emailController.text.trim();
    final String firstName = firstNameController.text.trim();
    final String lastName = lastNameController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      _showError('All fields are required!');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/users/signup/'), // Backend signup endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': email, // Using email as username
          'first_name': firstName,
          'last_name': lastName,
          'is_lawyer': isLawyer,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final String accessToken = responseData['access'];
        final bool isLawyerFromResponse = responseData['is_lawyer'];

        await saveAuthToken(accessToken);
        await saveEmail(email);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
              (route) => false,
        );
      } else {
        final responseData = jsonDecode(response.body);
        _showError(responseData['error'] ?? 'Signup failed. Please try again.');
      }
    } catch (e) {
      _showError('An error occurred. Please try again later.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
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
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFF5F5F5),
      ),
      backgroundColor: Color(0xFFF5F5F5), // White background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                // Logo
                Icon(
                  Icons.change_history, // Replace with your logo or image
                  size: 80,
                  color: Colors.blue, // Blue logo
                ),
                SizedBox(height: 20),
                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Let's Get Familiar",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Black text for the title
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Email input
                TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.black), // Black text
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // White input field background
                    hintText: "example@gmail.com",
                    hintStyle: TextStyle(color: Colors.grey[500]), // Light grey hint text
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // First Name and Last Name
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: firstNameController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white, // White input field background
                          hintText: 'First Name',
                          hintStyle: TextStyle(color: Colors.grey[500]), // Light grey hint text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: lastNameController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white, // White input field background
                          hintText: 'Last Name',
                          hintStyle: TextStyle(color: Colors.grey[500]), // Light grey hint text
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Password input
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
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
                // Re-enter Password input
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // White input field background
                    hintText: 'Re-Enter Password',
                    hintStyle: TextStyle(color: Colors.grey[500]), // Light grey hint text
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Switch for "Are you a lawyer?"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Are you a lawyer?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    Switch(
                      value: isLawyer,
                      onChanged: (value) {
                        setState(() {
                          isLawyer = value;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Join Now button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue button background
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Join Now",
                    style: TextStyle(color: Colors.white), // White text
                  ),
                ),
                SizedBox(height: 20),
                // Footer
                Text(
                  "By signing up I agree to Golden's terms of service\nand privacy policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600], // Grey footer text
                    fontSize: 12,
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
