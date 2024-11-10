import 'package:flutter/material.dart';
import 'package:hopehub/components/custom_charity_card_up.dart';
import 'package:hopehub/screens/charity_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // HTTP requests
import '../constants.dart';
import 'selection_screen.dart';
import 'dart:convert'; // For JSON decoding


class OverviewScreen extends StatefulWidget {
  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  var causes;
  var topics;
  List<dynamic> charities = [];
  List<dynamic> nearbyCharities = [];
  bool isLoading = true; // Loading indicator
  bool isLocationLoading = true; // Loading indicator
  bool hasSelectedPreferences = false; // Flag to check if user has preferences
  Map selectedPreferences = {};

  @override
  void initState() {
    super.initState();
    initializeScreen(); // Fetch user preferences and charities
  }

  Future<void> initializeScreen() async {
    final preferences = await checkIfUserHasSelectedCauses();
    setState(() {
      hasSelectedPreferences = preferences.isNotEmpty;
      selectedPreferences = preferences;
    });

    if (hasSelectedPreferences) {
      await fetchCharitiesFilteredByPreferences(preferences);
    } else {
      isLoading = false;
    }

  }

  Future<void> fetchCharitiesFilteredByPreferences(Map preferences) async {
    try {
      final causes = preferences['cause']?.join(',');
      final topics = preferences['topic']?.join(',');
      final response = await http.get(
        Uri.parse(
            '$BASE_URL/api/charities/?cause__name=$causes&topic__name=$topics'),
      );

      if (response.statusCode == 200) {
        setState(() {
          charities = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load charities');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  Future<Map> checkIfUserHasSelectedCauses() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedCauses = prefs.getStringList('selectedCauses');
    final selectedTopics = prefs.getStringList('selectedTopics');
    if (selectedCauses != null && selectedTopics != null) {
      return {
        'cause': selectedCauses,
        'topic': selectedTopics,
      };
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Impact Account Balance Card
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Impact Account balance',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(),
                      Text(
                        'Items Donated',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text(
                            '\$0.00',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.lightbulb_outline, color: Colors.blue),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '20',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.handshake_outlined, color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Add money'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 4),
                          Container(
                            width: 10,
                            height: 10,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Container(
                            width: 10,
                            height: 10,
                            color: Colors.purple,
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              child: hasSelectedPreferences
                  ? isLoading
                  ? Center(child: CircularProgressIndicator())
                  : charities.isEmpty
                  ? Center(
                  child: Text(
                      "No charities found for your preferences."))
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Charities matching your preferences:",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: charities.length,
                      itemBuilder: (context, index) {
                        final charity = charities[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CharityDetailsPage(
                                      charityId: charity['id'],
                                    ),
                              ),
                            );
                          },
                          child: _buildCharityCard(
                            charity['name'] ?? "Unknown Charity",
                            charity['image'] ?? "",
                            charity['cause'] ?? [],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset('images/illustration.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "When you select causes and topics, suggestions that match the interests of this account will appear here.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectionScreen(),
                        ),
                      );
                    },
                    child: Text('Select causes and topics',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Account Activity Section
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Account activity"),
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset('images/illustration2.jpg'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharityCard(String name, String imageUrl, List causes) {
    List allCauses = [];
    for (var i = 0; i < causes.length; i++) {
      allCauses.add(causes[i]['name']);
    }
    return CustomCharityCardUP(imageUrl: imageUrl, name: name, allCauses: allCauses);
  }

}
