import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants.dart';

class VolunteerDetailScreen extends StatefulWidget {
  final String id;
  const VolunteerDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<VolunteerDetailScreen> createState() => _VolunteerDetailScreenState();
}

class _VolunteerDetailScreenState extends State<VolunteerDetailScreen> {
  Map<String, dynamic>? volunteerData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchVolunteerDetails();
  }

  Future<void> fetchVolunteerDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/volunteers/${widget.id}/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          volunteerData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print("Error fetching volunteer details: $e");
    }
  }

  Future<void> signUpForVolunteer() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.68.104:8000/api/volunteers/volunteer-applications/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'random_token', // Include a valid token
        },
        body: json.encode({
          "volunteer": int.parse(widget.id), // Send the volunteer ID
        }),
      );

      if (response.statusCode == 201) {
        // Successful application
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed up successfully!')),
        );
      } else {
        // Handle API error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up. ${response.body}')),
        );
        print('Error: ${response.body}');
      }
    } catch (e) {
      // Handle any other error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
      print("Error signing up: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || volunteerData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Volunteer Details')),
        body: Center(child: Text('Failed to load volunteer details.')),
      );
    }

    final volunteer = volunteerData!;

    return Scaffold(
      appBar: AppBar(
        title: Text(volunteer['title'] ?? 'Volunteer Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Handle sharing action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: Image.network(
                volunteer['image'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'images/volunteer_place_holder.png', // Replace with actual asset path
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            // Title and Organization Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    volunteer['title'] ?? 'Unknown Title',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    volunteer['organization'] ?? 'Unknown Organization',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),

            // Description Section
            _buildSection('Description', volunteer['description'] ?? 'No description available.'),
            Divider(),

            // Purpose Section
            _buildSection('Purpose', volunteer['purpose'] ?? 'No purpose available.'),
            Divider(),

            // Role Section
            _buildSection('Role', volunteer['role'] ?? 'No role available.'),
            Divider(),

            // Vibe Section
            _buildSection('Vibe', volunteer['vibe'] ?? 'No vibe available.'),
            Divider(),

            // Date & Time Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date & Time',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${volunteer['start_date'] ?? ''} - ${volunteer['end_date'] ?? ''}\n${volunteer['start_time'] ?? ''} - ${volunteer['end_time'] ?? ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      signUpForVolunteer(); // Call the API when "Sign Up" is pressed
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Sign Up'),
                  ),
                ],
              ),
            ),
            Divider(),

            // Indoor/Outdoor, Active/Mellow, etc.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoTile('Indoor/Outdoor', volunteer['indoor_outdoor'] ?? 'N/A'),
                  _buildInfoTile('Active/Mellow', volunteer['active_mellow'] ?? 'N/A'),
                  _buildInfoTile('Mind/Body', volunteer['mind_body'] ?? 'N/A'),
                  _buildInfoTile('Independent/Social', volunteer['independent_social'] ?? 'N/A'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
