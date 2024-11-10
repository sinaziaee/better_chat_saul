import 'package:flutter/material.dart';
import 'package:hopehub/screens/charity_screen.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // HTTP requests
import 'package:hopehub/screens/selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/charity_card.dart';
import '../components/custom_charity_card_up.dart';
import '../constants.dart';

class SearchGiveScreen extends StatefulWidget {
  @override
  _SearchGiveScreenState createState() => _SearchGiveScreenState();
}

class _SearchGiveScreenState extends State<SearchGiveScreen> {
  List<dynamic> charities = [];
  List<dynamic> nearbyCharities = [];
  bool isLoading = true; // Loading indicator
  bool isLocationLoading = true; // Loading indicator
  bool hasSelectedPreferences = false; // Flag to check if user has preferences
  Map selectedPreferences = {}; // Stores user's selected causes and topics

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

    await fetchCharitiesNearby(preferences);
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

  Future<void> fetchCharitiesNearby(Map preferences) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$BASE_URL/api/charities/location/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          nearbyCharities = json.decode(response.body);
          isLocationLoading = false;
        });
      } else {
        setState(() {
          isLocationLoading = false;
        });
        throw Exception('Failed to load charities');
      }
    } catch (e) {
      setState(() {
        isLocationLoading = false;
      });
      print("Error: $e");
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for somewhere to give',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("What’s nearby"),
          ),
          Expanded(
            child: isLocationLoading
                ? Center(child: CircularProgressIndicator())
                : nearbyCharities.isEmpty
                    ? Center(child: Text("No charities found"))
                    : ListView.builder(
                        itemCount: nearbyCharities.length,
                        itemBuilder: (context, index) {
                          final charity = nearbyCharities[index];
                          print(charity['address']);
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CharityDetailsPage(
                                    charityId: charity['id'],
                                  ),
                                ),
                              );
                            },
                            child: _buildNearbyCard(
                              charity['name'] ?? "Unknown Charity",
                              charity['description'] ??
                                  "No description available",
                              charity['image'] ?? "",
                              charity['cause'] ?? [],
                              charity['location'] ?? "Calgary",
                              charity['address'] ?? "1234 Charity St",
                            ),
                          );
                        },
                      ),
          ),
        ],
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

  Widget _buildNearbyCard(
      String title, String subtitle, String imageUrl, List causes, String location, String address) {
    List allCauses = [];
    for (var i = 0; i < causes.length; i++) {
      allCauses.add(causes[i]['name']);
    }
    return CustomCharityCard(
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      allCauses: allCauses,
      location: location,
      address: address,
    );
  }
}
