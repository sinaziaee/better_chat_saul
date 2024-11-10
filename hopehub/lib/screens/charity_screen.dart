import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;

import '../constants.dart'; // HTTP requests

class CharityDetailsPage extends StatefulWidget {
  final int charityId; // ID of the charity to fetch data for

  const CharityDetailsPage({Key? key, required this.charityId})
      : super(key: key);

  @override
  _CharityDetailsPageState createState() => _CharityDetailsPageState();
}

class _CharityDetailsPageState extends State<CharityDetailsPage> {
  Map<String, dynamic>? charityData; // Holds the fetched charity data
  bool isLoading = true; // Loading state
  bool hasError = false; // Error state
  bool showFullDescription = false; // To toggle full description visibility

  @override
  void initState() {
    super.initState();
    fetchCharityDetails(); // Fetch data when the page loads
  }

  Future<void> fetchCharityDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$BASE_URL/api/charities/${widget.charityId}/'), // Replace with your API endpoint
      );

      if (response.statusCode == 200) {
        setState(() {
          charityData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        throw Exception('Failed to load charity details');
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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Charity Details'),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(), // Show loading spinner
        ),
      );
    }

    if (hasError || charityData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Charity Details'),
          centerTitle: true,
        ),
        body: Center(
          child:
              Text('Failed to load charity details. Please try again later.'),
        ),
      );
    }

    final charity = charityData!;

    return Scaffold(
      appBar: AppBar(
        title: Text(charity['name'] ?? 'Charity Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Charity Header Section
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  charity['image'] != null
                      ? Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(charity['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.orange,
                          child: Icon(Icons.account_balance,
                              color: Colors.white, size: 80),
                        ),
                  SizedBox(height: 16),
                  Text(
                    charity['name'] ?? 'Charity Name',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Charitable Organization',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  SizedBox(height: 16),
                  // Description Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showFullDescription
                            ? charity['description'] ??
                                'No description available.'
                            : (charity['description'] ??
                                        'No description available.')
                                    .substring(0, 100) +
                                '...',
                        style: TextStyle(fontSize: 14),
                      ),
                      if (charity['description'] != null &&
                          (charity['description'] as String).length > 400)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showFullDescription = !showFullDescription;
                            });
                          },
                          child: Text(
                            showFullDescription ? 'Read Less' : 'Read More',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    children: (charity['cause'] ?? [])
                        .map<Widget>(
                          (cause) => Chip(
                            label: Text(cause['name']),
                            backgroundColor: Colors.blue[50],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            Divider(),

            // CRA Registration Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CRA registration number:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    charity['cra_registration_number'] ?? 'N/A',
                    style: TextStyle(color: Colors.black87),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(charity['phone'] ?? 'N/A'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(charity['email'] ?? 'N/A'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          charity['address'] ?? 'N/A',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${charity['name']} is registered with the Canada Revenue Agency.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),

            // Revenue and Expenses Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue and expenses',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExpenseItem(
                          'Total Revenue',
                          charity['revenue_expenses']?['total_revenue'] ??
                              'N/A'),
                      _buildExpenseItem(
                          'Total Expenses',
                          charity['revenue_expenses']?['total_expenses'] ??
                              'N/A'),
                      _buildExpenseItem(
                          'Charitable Activities',
                          charity['revenue_expenses']
                                  ?['charitable_activities'] ??
                              'N/A'),
                      _buildExpenseItem(
                          'Management and Administration',
                          charity['revenue_expenses']
                                  ?['management_and_administration'] ??
                              'N/A'),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Contact charity', style: TextStyle(color: Colors.white),),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Claim charity', style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(String title, dynamic amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            '\$$amount',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
