import 'package:flutter/material.dart';

class TopicsScreen extends StatefulWidget {
  final Set<String> selectedTopics;

  const TopicsScreen({super.key, required this.selectedTopics});

  @override
  _TopicsScreenState createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  late Set<String> selectedTopics;

  final List<String> topics = [
    'aboriginal',
    'adolescent',
    'adventure',
    'adventure-sports',
    'advocacy',
    'africa',
    'agility',
    'agility-sports',
    'agriculture',
    'air-force',
    'alternative-health',
    'animal-hospital',
    'animal-protection',
    'anti-racism',
  ];

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedTopics = Set.from(widget.selectedTopics);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTopics = topics
        .where((topic) => topic.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Topics'),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search topics',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredTopics.length,
              itemBuilder: (context, index) {
                final topic = filteredTopics[index];
                final isSelected = selectedTopics.contains(topic);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedTopics.remove(topic);
                      } else {
                        selectedTopics.add(topic);
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            topic,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.check : Icons.add,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedTopics);
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
