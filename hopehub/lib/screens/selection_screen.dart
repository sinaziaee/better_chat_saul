import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'causes_screen.dart';
import 'topics_screen.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  // Store selected causes and topics
  Set<String> selectedCauses = {};
  Set<String> selectedTopics = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCauses = (prefs.getStringList('selectedCauses') ?? []).toSet();
      selectedTopics = (prefs.getStringList('selectedTopics') ?? []).toSet();
    });
  }

  // Save preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedCauses', selectedCauses.toList());
    await prefs.setStringList('selectedTopics', selectedTopics.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Causes and topics'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Instruction Text
                Text(
                  'Select causes and topics to see suggestions that match the interests of this account. These suggestions will appear when you search for somewhere to give.',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 16),
                Divider(),

                // Causes Section
                ListTile(
                  title: Text('Causes'),
                  subtitle: selectedCauses.isEmpty
                      ? Text('Causes represent broader areas of charitable interests.')
                      : Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: selectedCauses
                        .map((cause) => Chip(
                      label: Text(cause),
                      backgroundColor: Colors.blue,
                      labelStyle: TextStyle(color: Colors.white),
                    ))
                        .toList(),
                  ),
                  trailing: Icon(
                    selectedCauses.isEmpty ? Icons.arrow_forward_ios : Icons.edit,
                    color: Colors.blue,
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CausesScreen(selectedCauses: selectedCauses),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        selectedCauses = result;
                      });
                    }
                  },
                ),
                Divider(),

                // Topics Section
                ListTile(
                  title: Text('Topics'),
                  subtitle: selectedTopics.isEmpty
                      ? Text('Topics represent specific areas of charitable interests.')
                      : Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: selectedTopics
                        .map((topic) => Chip(
                      label: Text(topic),
                      backgroundColor: Colors.blue,
                      labelStyle: TextStyle(color: Colors.white),
                    ))
                        .toList(),
                  ),
                  trailing: Icon(
                    selectedTopics.isEmpty ? Icons.arrow_forward_ios : Icons.edit,
                    color: Colors.blue,
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TopicsScreen(selectedTopics: selectedTopics),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        selectedTopics = result;
                      });
                    }
                  },
                ),
                Divider(),

                // Footer Text
                SizedBox(height: 16),
                Text(
                  'Causes and topics you select are shown on the Impact Account profile. You can adjust the privacy settings to control who can see this information. We do not share selected causes and topics with charities.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Save Button at the Bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                // Save selections to SharedPreferences
                await _savePreferences();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selections have been saved.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context, {
                  'causes': selectedCauses,
                  'topics': selectedTopics,
                });
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
