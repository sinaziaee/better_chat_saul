import 'package:flutter/material.dart';
import 'package:hopehub/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bono/create_case.dart';

class AppDrawer extends StatefulWidget {
  final Function(bool) onStatusChange; // Callback function to notify MainPage

  AppDrawer({required this.onStatusChange});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isLawyer = false;

  Future<void> clearAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? 'null';
  }

  Future<void> loadIsLawyer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLawyer = prefs.getBool('is_lawyer') ?? false; // Default to false
    });
  }

  Future<void> updateIsLawyer(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLawyer = value;
    });
    await prefs.setBool('is_lawyer', value);
    widget.onStatusChange(value); // Notify MainPage of the change
  }

  @override
  void initState() {
    super.initState();
    loadIsLawyer();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  FutureBuilder(
                    future: getAuthToken(),
                    builder: (context, snapshot) {
                      return snapshot.connectionState == ConnectionState.waiting
                          ? Text('Loading...', style: TextStyle(color: Colors.white))
                          : Text(
                        snapshot.data ?? 'Guest',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                  // Text(
                  //   'View profile',
                  //   style: TextStyle(
                  //     color: Colors.white70,
                  //     fontSize: 14,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.receipt),
          //   title: Text('Tax receipts'),
          //   onTap: () {},
          // ),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text('Settings'),
          //   onTap: () {},
          // ),
          // Divider(),
          // Add Case option for non-lawyers
          if (!isLawyer)
            ListTile(
              leading: Icon(Icons.add_box),
              title: Text('Add Case'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateCaseScreen(), // Navigate to the CreateCaseScreen
                  ),
                );
              },
            ),
          Divider(),
          // Lawyer Switch
          ListTile(
            leading: Icon(Icons.gavel),
            title: Text('Lawyer Status'),
            trailing: Switch(
              value: isLawyer,
              onChanged: (value) async {
                await updateIsLawyer(value);
              },
              activeColor: Colors.blue,
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              'Log out',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: () async {
              await clearAuthToken();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    (route) => false, // Removes all previous routes
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'V-1.2.1',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
