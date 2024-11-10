import 'package:flutter/material.dart';
import 'package:hopehub/constants.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests
import 'volunteer_detail_screen.dart';

class VolunteerScreen extends StatefulWidget {
  @override
  _VolunteerScreenState createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  List<dynamic> volunteerItems = []; // Holds the volunteer items fetched from the API
  bool isLoading = true; // Loading state
  bool hasError = false; // Error state

  @override
  void initState() {
    super.initState();
    fetchVolunteers(); // Fetch the volunteers when the screen loads
  }

  Future<void> fetchVolunteers() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/volunteers/'), // Replace with your API endpoint
      );

      if (response.statusCode == 200) {
        setState(() {
          volunteerItems = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        throw Exception('Failed to load volunteers');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover Volunteers'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : hasError
          ? Center(child: Text('Failed to load volunteers. Please try again later.'))
          : ListView.builder(
        itemCount: volunteerItems.length,
        padding: EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          final item = volunteerItems[index];
          print(item['image']);
          return GestureDetector(
            onTap: () {
              // Navigate to the details screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VolunteerDetailScreen(
                    id: item['id'].toString(),
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section with Fallback
                  ClipRRect(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12.0)),
                    child: Image.network(
                      item['image'] ?? '',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to asset image if the network image fails
                        return Image.asset(
                          'images/volunteer_place_holder.png', // Replace with the actual asset path
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),

                  // Text Details Section
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? 'Unknown Title',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          item['organization'] ?? 'Unknown Organization',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16.0, color: Colors.blue),
                            SizedBox(width: 4.0),
                            Text(
                              '${item['start_date'] ?? ''}', // Use start_date from API
                              style: TextStyle(fontSize: 14.0),
                            ),
                            if (item['end_date'] != null) ...[
                              Text(' - ${item['end_date']}'),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
