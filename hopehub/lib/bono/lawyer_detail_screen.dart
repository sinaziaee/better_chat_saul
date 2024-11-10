import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hopehub/constants.dart';
import 'package:http/http.dart' as http;

class LawyerDetailScreen extends StatefulWidget {
  final int lawyerId;

  LawyerDetailScreen({required this.lawyerId});

  @override
  _LawyerDetailScreenState createState() => _LawyerDetailScreenState();
}

class _LawyerDetailScreenState extends State<LawyerDetailScreen> {
  Map<String, dynamic>? lawyerDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLawyerDetails();
  }

  Future<void> fetchLawyerDetails() async {
    String apiUrl = '$BASE_URL/api/bono/lawyers/${widget.lawyerId}/';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          lawyerDetail = json.decode(response.body);
          print(lawyerDetail!['bio']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load lawyer details');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching lawyer details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lawyer Details'),
        // backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : lawyerDetail == null
          ? Center(child: Text('Failed to load lawyer details.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: lawyerDetail!['profile_image'] !=
                      null &&
                      lawyerDetail!['profile_image'].isNotEmpty
                      ? NetworkImage(lawyerDetail!['profile_image'])
                      : null,
                  child: lawyerDetail!['profile_image'] == null ||
                      lawyerDetail!['profile_image'].isEmpty
                      ? Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  lawyerDetail!['user']['username'] ?? 'Unknown Lawyer',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Specialization: ${lawyerDetail!['specialization'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Rating: ${lawyerDetail!['rating']?.toStringAsFixed(1) ?? 'N/A'}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                lawyerDetail!['is_verified'] == true
                    ? 'Verified Lawyer'
                    : 'Not Verified',
                style: TextStyle(
                  fontSize: 18,
                  color: lawyerDetail!['is_verified'] == true
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Bio:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                lawyerDetail!['bio'] ?? 'No bio available.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
