import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hopehub/constants.dart';
import 'package:http/http.dart' as http;

import 'lawyer_detail_screen.dart';

class LawyersListScreen extends StatefulWidget {
  @override
  _LawyersListScreenState createState() => _LawyersListScreenState();
}

class _LawyersListScreenState extends State<LawyersListScreen> {
  List<dynamic> lawyers = [];
  List<dynamic> filteredLawyers = [];
  bool isLoading = true;
  String selectedSpecialization = 'All';
  bool isVerifiedFilter = false; // Default: show all lawyers

  // Specialization options from the Django model
  final List<String> specializations = [
    'All',
    'Criminal Law',
    'Family Law',
    'Corporate Law',
    'Intellectual Property',
    'Immigration Law',
    'Labor Law',
    'Real Estate Law',
    'Tax Law',
    'Environmental Law',
    'Health Law',
    'Human Rights Law',
    'Contract Law',
    'International Law',
  ];

  @override
  void initState() {
    super.initState();
    fetchLawyers();
  }

  Future<void> fetchLawyers() async {
    String apiUrl = '$BASE_URL/api/bono/lawyers/';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          lawyers = data;
          filteredLawyers = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load lawyers');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching lawyers: $error');
    }
  }

  void filterLawyers() {
    setState(() {
      filteredLawyers = lawyers.where((lawyer) {
        final matchesSpecialization = selectedSpecialization == 'All' ||
            lawyer['specialization'] == selectedSpecialization;
        final matchesVerification =
            isVerifiedFilter == false || lawyer['is_verified'] == true;
        return matchesSpecialization && matchesVerification;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filters: Specialization Dropdown and Verified Toggle
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: selectedSpecialization,
                  isExpanded: true,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedSpecialization = value;
                      });
                      filterLawyers();
                    }
                  },
                  items: specializations.map((specialization) {
                    return DropdownMenuItem<String>(
                      value: specialization,
                      child: Text(specialization),
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Show Verified Lawyers Only',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: isVerifiedFilter,
                      onChanged: (value) {
                        setState(() {
                          isVerifiedFilter = value;
                        });
                        filterLawyers();
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Lawyers List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredLawyers.isEmpty
                ? Center(child: Text('No lawyers available for this filter.'))
                : ListView.builder(
              itemCount: filteredLawyers.length,
              itemBuilder: (context, index) {
                final lawyer = filteredLawyers[index];
                final profileImage = lawyer['profile_image'];

                return Card(
                  margin: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: profileImage != null &&
                          profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : null,
                      child: profileImage == null || profileImage.isEmpty
                          ? Icon(Icons.account_circle, size: 40)
                          : null,
                    ),
                    title: Text(
                      lawyer['user']['username'] ?? 'Unknown Lawyer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lawyer['specialization'] ??
                          'Specialization not provided',
                    ),
                    trailing: lawyer['is_verified']
                        ? Column(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.blue),
                        Text('Verified',),
                      ],
                    )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LawyerDetailScreen(lawyerId: lawyer['id']),
                        ),
                      );                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
