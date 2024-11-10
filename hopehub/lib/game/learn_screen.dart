import 'package:flutter/material.dart';
import 'package:hopehub/constants.dart';
import 'package:hopehub/game/quiz_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LearnScreen extends StatefulWidget {
  final int id;
  final String token;
  final Map data;

  const LearnScreen({Key? key, required this.id, required this.token, required this.data})
      : super(key: key);

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  Map<String, dynamic>? learnData; // Store learn data
  bool isLoading = true; // Loading indicator
  bool hasError = false; // Error indicator

  void navigator(){
    if (widget.data['learn_no'] == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(id: widget.data['quizzes'][0]['id'], token: widget.token, data: widget.data),
        ),
      );
    }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LearnScreen(id: widget.data['learns'][0]['id'], token: widget.token, data: widget.data),
        ),
      );
    }
  }

  void update_data() {
    print(widget.data);
    widget.data['learn_no'] -= 1;
    // widget.data['quiz_no'] -= 1;
    widget.data['learns'].removeAt(0);
    // print(widget.data['learns']);
    // widget.data['quizzes'].removeAt(0);
  }

  @override
  void initState() {
    super.initState();
    fetchLearnData();
    update_data();
  }

  Future<void> fetchLearnData() async {
    try {
      final response = await http
          .get(Uri.parse('$BASE_URL/api/game/learns/${widget.id}/'), headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        setState(() {
          learnData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load learn data');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Error fetching learn data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/game_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? Center(
                    child: Text(
                      'Failed to load data',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50), // Top padding
                      Center(
                        child: learnData?['image'] != null
                            ? Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  color: Colors
                                      .black, // Optional background color for the container
                                ),
                                clipBehavior: Clip.antiAlias,
                                // Ensures rounded corners apply to the image
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  // Adjust the aspect ratio as per your design
                                  child: Image.network(
                                    '${learnData!['image']}',
                                    // Ensure the full image URL is correct
                                    fit: BoxFit
                                        .cover, // Ensures the image scales to fill the container
                                  ),
                                ),
                              )
                            : Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 16.0),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('images/question-mark.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                  color: Colors
                                      .white, // Optional background color for the container
                                ),
                                clipBehavior: Clip.antiAlias,
                                // Ensures rounded corners apply to the image
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  // Adjust the aspect ratio as per your design
                                  // child: Text(
                                  //   'No image available',
                                  //   style: TextStyle(color: Colors.white),
                                  // ),
                                ),
                              ),
                      ),
                      // const SizedBox(height: 20),
                      // Text(
                      //   learnData?['title'] ?? 'Unknown Title',
                      //   style: const TextStyle(
                      //     fontSize: 30,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.white,
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            learnData?['content'] ?? 'No content available',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Define what happens when Next is pressed
                            navigator();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blueGrey, // Brown button color
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
      ),
    );
  }
}
