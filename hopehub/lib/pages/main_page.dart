import 'package:flutter/material.dart';
import 'package:hopehub/components/drawer.dart';
import 'package:hopehub/game/road_map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../bono/cases_list_screen.dart';
import '../bono/lawyers_list_screen.dart';
import '../constants.dart';
import '../screens/profile_donation_screen.dart';
import '../screens/overview_screen.dart';
import 'package:http/http.dart' as http;
import '../chat/chat_list_screen.dart'; // Import ChatSessionsPage

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool isLawyer = false;
  String? token;
  bool isLoading = true;
  bool hasError = false;
  int points = 20;

  final List<Widget> _pages = [
    // OverviewScreen(),
    // SearchGiveScreen(),
    RoadMapScreen(),
    ChatSessionsPage(), // Replaced VolunteerScreen with ChatSessionsPage
    // ProfileDonationScreen(),
    Container(), // Placeholder for Lawyer/Cases Screen
  ];

  @override
  void initState() {
    super.initState();
    _loadLawyerStatus();
    fetchData();
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      token = await getAuthToken();

      if (token == null) {
        throw Exception('Authorization token not found');
      }

      // Fetch contents
      final contentsResponse = await http.get(
        Uri.parse('$BASE_URL/api/game/users/game-info/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (contentsResponse.statusCode == 200) {
        setState(() {
          final data = jsonDecode(contentsResponse.body);
          print("--------------------");
          points = data['points'];
          isLoading = false;
        });
      }
      else if (contentsResponse.statusCode == 202) {
        final data = jsonDecode(contentsResponse.body);
        points = data['points'];
        isLoading = false;
      }
      else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Error fetching data: $error');
    }
  }

  Future<void> _loadLawyerStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLawyer = prefs.getBool('is_lawyer') ?? false;
      _pages[2] = isLawyer ? CasesListScreen() : LawyersListScreen();
    });
  }

  void _updateLawyerStatus(bool status) {
    setState(() {
      isLawyer = status;
      _pages[2] = isLawyer ? CasesListScreen() : LawyersListScreen();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        backgroundColor: Colors.blue,
        title:
            _selectedIndex == 1
                ? Text('Chat Sessions', style: TextStyle(color: Colors.white),)
                : _selectedIndex == 0
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.point_of_sale, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '25',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(width: 20),
                          Icon(Icons.currency_bitcoin, color: Colors.white),
                          SizedBox(width: 2),
                          Text(
                            '2',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      )
                    : _selectedIndex == 2
                        ? (isLawyer ? Text('Cases', style: TextStyle(color: Colors.white),) : Text('Lawyers', style: TextStyle(color: Colors.white),))
                        : Text('sina z', style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      drawer: AppDrawer(
        onStatusChange: _updateLawyerStatus,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.dashboard),
          //   label: 'Overview',
          // ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            label: 'Learning Game',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat), // Updated icon to represent chat
            label: 'Chat Bot', // Updated label to represent chat
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.monetization_on),
          //   label: 'Deposits & Gifts',
          // ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.gavel),
            label: isLawyer ? 'Cases' : 'Lawyers',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
      ),
    );
  }
}
