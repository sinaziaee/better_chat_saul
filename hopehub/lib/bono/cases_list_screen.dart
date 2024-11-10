import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hopehub/constants.dart';
import 'package:http/http.dart' as http;

import 'case_detail_screen.dart';

class CasesListScreen extends StatefulWidget {
  @override
  _CasesListScreenState createState() => _CasesListScreenState();
}

class _CasesListScreenState extends State<CasesListScreen> {
  List<dynamic> cases = [];
  List<dynamic> filteredCases = [];
  bool isLoading = true;
  String selectedCategory = 'All';

  // Categories for filtering
  final List<String> categories = [
    'All',
    'Criminal',
    'Family',
    'Corporate',
    'Intellectual Property',
    'Immigration',
    'Labor',
    'Real Estate',
    'Tax',
    'Environmental',
    'Health',
    'Human Rights',
    'Contract',
    'International',
  ];

  @override
  void initState() {
    super.initState();
    fetchCases();
  }

  Future<void> fetchCases() async {
    String apiUrl = '$BASE_URL/api/bono/cases/'; // Updated API endpoint
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cases = data;
          filteredCases = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cases');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching cases: $error');
    }
  }

  void filterCases(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredCases = cases;
      } else {
        filteredCases = cases.where((caseItem) {
          return caseItem['category'] == category;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Category Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              onChanged: (value) {
                if (value != null) {
                  filterCases(value);
                }
              },
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
          ),
          // Cases List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredCases.isEmpty
                ? Center(child: Text('No cases available for this category.'))
                : ListView.builder(
              itemCount: filteredCases.length,
              itemBuilder: (context, index) {
                final caseItem = filteredCases[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      caseItem['title'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      children: [
                        Text(
                          caseItem['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                caseItem['category'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Text(
                      caseItem['status'],
                      style: TextStyle(
                        color: caseItem['status'] == 'Open'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CaseDetailScreen(caseId: caseItem['id']),
                        ),
                      );
                    },
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
