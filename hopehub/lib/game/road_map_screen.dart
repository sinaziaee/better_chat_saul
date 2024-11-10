import 'package:flutter/material.dart';
import 'package:hopehub/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'components/hexagon.dart';
import 'learn_screen.dart';

class RoadMapScreen extends StatefulWidget {
  @override
  _RoadMapScreenState createState() => _RoadMapScreenState();
}

class _RoadMapScreenState extends State<RoadMapScreen> {
  List<dynamic> contents = [];
  Set<int> seenContentIds = {}; // Track IDs of seen contents
  bool isLoading = true;
  bool hasError = false;
  String? token;
  final ScrollController _scrollController =
      ScrollController(); // ScrollController to manage scrolling

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Fetch contents and seen contents
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
        Uri.parse('$BASE_URL/api/game/contents/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Fetch seen contents
      final seenContentsResponse = await http.get(
        Uri.parse('$BASE_URL/api/game/users/seen-contents/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (contentsResponse.statusCode == 200 &&
          seenContentsResponse.statusCode == 200) {
        setState(() {
          contents = jsonDecode(contentsResponse.body);
          seenContentIds = (jsonDecode(seenContentsResponse.body) as List)
              .map<int>((content) => content['id'] as int)
              .toSet();
          isLoading = false;

          // Scroll to the first unseen content
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToFirstUnseen();
          });
        });
      } else if (contentsResponse.statusCode == 200 &&
          seenContentsResponse.statusCode == 202) {
        contents = jsonDecode(contentsResponse.body);
        isLoading = false;
        seenContentIds = {};
        setState(() {

        });
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   scrollToFirstUnseen();
        // });
      } else {
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

  Future<void> updateSeenContentsData() async {
    // setState(() {
    //   isLoading = true;
    //   hasError = false;
    // });

    try {
      // token = await getAuthToken();
      //
      // if (token == null) {
      //   throw Exception('Authorization token not found');
      // }
      print(token);
      // Fetch contents
      final contentsResponse = await http.patch(
        Uri.parse('$BASE_URL/api/game/users/game-info/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "learned_contents": [1, 2, 3, 4, 5],
        }),
      );

      if (contentsResponse.statusCode == 200) {
        // setState(() {
        contents = jsonDecode(contentsResponse.body);
        print(contents);
        // });
      } else {
        throw Exception('Failed to update data');
      }
    } catch (error) {
      // setState(() {
      //   hasError = true;
      //   isLoading = false;
      // });
      print('Error Updating data: $error');
    }
  }

  void scrollToFirstUnseen() {
    // Find the index of the first unseen item
    int index = contents
        .indexWhere((content) => !seenContentIds.contains(content['id']));
    if (index != -1) {
      // Scroll to the index of the first unseen item
      _scrollController.animateTo(
        index * 120.0,
        // Assuming each item has a height of 120. Adjust as needed.
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool firstUnseenFound = false; // Track if the first unseen content is found

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'images/game_background.png', // Path to the background image
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          isLoading
              ? Center(child: CircularProgressIndicator())
              : hasError
                  ? Center(
                      child: Text(
                        'Failed to load contents',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    )
                  : SingleChildScrollView(
                      controller:
                          _scrollController, // Attach ScrollController here
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(contents.length, (index) {
                            final content = contents[index];
                            final level = index + 1; // Levels start from 1
                            final isSeen =
                                seenContentIds.contains(content['id']);
                            final List learns_ids = content['learns'];
                            final List quizes_ids = content['quizzes'];

                            final Map result = find_no_learns_and_quizes(
                                learns_ids, quizes_ids);

                            // Help here, based on the number of learns and quizes, I want to go to learn_screen.dart or quiz_screen.dart accordingly (if learn_no = 3 go to learn_screen.dart 3 times, and if quiz_no = 2 go to quiz_screen.dart 2 times)

                            // Determine the color
                            Color contentColor;
                            if (isSeen) {
                              contentColor =
                                  Colors.grey; // Mark seen contents as grey
                            } else if (!firstUnseenFound) {
                              contentColor = Colors
                                  .green; // Mark the first unseen as green
                              firstUnseenFound = true; // Update flag
                            } else {
                              contentColor =
                                  Colors.blue; // Other unseen contents as blue
                            }
                            return GestureDetector(
                              onTap: () {
                                // updateSeenContentsData();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LearnScreen(
                                        id: result['learns'][0]['id'],
                                        token: token!,
                                        data: result),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  if (index > 0)
                                    Container(
                                      height: 30,
                                      width: 2,
                                      color: Colors
                                          .black, // Vertical line connecting levels
                                    ),
                                  Hexagon(
                                    level: level,
                                    title: content[
                                        'title'], // Use title from backend
                                    color: contentColor,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Map find_no_learns_and_quizes(List learns_ids, List quizes_ids) {
    return {
      "learn_no": learns_ids.length,
      "quiz_no": quizes_ids.length,
      "learns": learns_ids,
      "quizzes": quizes_ids,
      "points": 0,
    };
  }
}
