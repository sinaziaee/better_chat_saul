import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hopehub/screens/volunteer_screen.dart';
import 'components/drawer.dart';
import 'pages/main_page.dart';
import 'screens/profile_donation_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/search_screen.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blueAccent,
        secondaryHeaderColor: Colors.blueGrey,
      ),
      home: SplashScreen(), // Set SplashScreen as the initial route
      debugShowCheckedModeBanner: false,
    );
  }
}

// SplashScreen to Check for Auth Token
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus(); // Call the auth check function
  }

  Future<void> _checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); // Check if token exists

    if (token != null) {
      // Token exists, navigate to the MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      // No token, navigate to the Welcome Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show a loader while checking auth
      ),
    );
  }
}

