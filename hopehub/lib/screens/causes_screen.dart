import 'package:flutter/material.dart';

class CausesScreen extends StatefulWidget {
  final Set<String> selectedCauses;

  const CausesScreen({super.key, required this.selectedCauses});

  @override
  _CausesScreenState createState() => _CausesScreenState();
}

class _CausesScreenState extends State<CausesScreen> {
  late Set<String> selectedCauses;

  final List<Map<String, dynamic>> causes = [
    {'name': 'Amenities', 'icon': Icons.location_city},
    {'name': 'Animals', 'icon': Icons.pets},
    {'name': 'Arts and culture', 'icon': Icons.brush},
    {'name': 'Community development', 'icon': Icons.group},
    {'name': 'Education and research', 'icon': Icons.science},
    {'name': 'Environment', 'icon': Icons.eco},
    {'name': 'Health', 'icon': Icons.health_and_safety},
    {'name': 'Human rights', 'icon': Icons.people},
    {'name': 'International', 'icon': Icons.public},
    {'name': 'Outreach and welfare', 'icon': Icons.volunteer_activism},
    {'name': 'Religion and spirituality', 'icon': Icons.star},
    {'name': 'Sports and recreation', 'icon': Icons.sports},
    {'name': 'Youth/children', 'icon': Icons.backpack},
    {'name': 'Other', 'icon': Icons.lightbulb},
  ];


  @override
  void initState() {
    super.initState();
    selectedCauses = Set.from(widget.selectedCauses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Causes'),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: causes.length,
              itemBuilder: (context, index) {
                final cause = causes[index]['name'];
                final icon = causes[index]['icon'];
                final isSelected = selectedCauses.contains(cause);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedCauses.remove(cause);
                      } else {
                        selectedCauses.add(cause);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          color: isSelected ? Colors.white : Colors.grey,
                          size: 36,
                        ),
                        SizedBox(height: 8),
                        Text(
                          cause,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
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
                Navigator.pop(context, selectedCauses);
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
