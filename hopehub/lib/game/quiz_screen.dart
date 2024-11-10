import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hopehub/game/road_map_screen.dart';
import 'package:hopehub/pages/main_page.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;

import '../constants.dart';
import 'learn_screen.dart'; // For API calls

class QuizScreen extends StatefulWidget {
  final String token;
  final int id;
  final Map data;

  const QuizScreen(
      {Key? key, required this.token, required this.id, required this.data})
      : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, dynamic>? quizData; // Store the quiz data
  bool isLoading = true;
  bool showFeedback = false;
  String feedbackMessage = '';
  List<String> options = [];

  int? selectedOptionIndex;
  bool? isCorrect;
  int? questionPoint;

  void update_data() {
    print(widget.data);
    // widget.data['learn_no'] -= 1;
    widget.data['quiz_no'] -= 1;
    // widget.data['learns'].removeAt(0);
    widget.data['quizzes'].removeAt(0);
  }

  void update_points() {
    if (isCorrect == true) {
      widget.data['points'] += questionPoint;
    }
  }

  void navigator() {
    update_points();
    if (widget.data['quiz_no'] == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
              id: widget.data['quizzes'][0]['id'],
              token: widget.token,
              data: widget.data),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchQuiz();
    update_data();
  }

  Future<void> fetchQuiz() async {
    // String apiUrl = '$BASE_URL/api/game/quizzes/${widget.id}/';
    String apiUrl = '$BASE_URL/api/game/quizzes/${widget.id}/';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          quizData = json.decode(response.body);
          print("-------------------------------");
          print(quizData);
          questionPoint = quizData?['point'];

          // Collect options
          List<String?> tempList = [
            quizData?['option1'],
            quizData?['option2'],
            quizData?['option3'],
            quizData?['option4']
          ];

          // Filter out null options
          options = tempList.whereType<String>().toList();

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load quiz');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        feedbackMessage = 'Error fetching quiz: $e';
        showFeedback = true;
      });
    }
  }

  void checkAnswer(int selectedOption) {
    if (quizData != null) {
      int correctOption = quizData!['answer'];

      setState(() {
        selectedOptionIndex = selectedOption;
        isCorrect = selectedOption == correctOption;

        showFeedback = true;
        feedbackMessage = isCorrect! ? 'Correct! 🎉' : 'Wrong! Try again.';
      });

      // Navigate to RoadmapScreen after 1-second delay
      Future.delayed(const Duration(seconds: 1), () {
        navigator();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Quiz'),
      //   centerTitle: true,
      // ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : quizData == null
              ? Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/game_background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text('No quiz available.'),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/game_background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: Column(
                      children: [
                        SizedBox(height: 150),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            quizData!['question'],
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 80),
                        ...List.generate(options.length, (index) {
                          final option = options[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: selectedOptionIndex == index
                                  ? (isCorrect != null && isCorrect!
                                  ? Colors.green
                                  : Colors.red)
                                  : Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            key: ValueKey(option),
                            margin: EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              onTap: () => checkAnswer(index),
                              leading: Icon(Icons.add_circle_outlined),
                              title: Text(
                                option,
                                style: TextStyle(fontSize: 18),
                              ),
                              tileColor: selectedOptionIndex == index
                                  ? (isCorrect != null && isCorrect!
                                      ? Colors.green
                                      : Colors.red)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          );
                        }),
                        if (showFeedback)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              feedbackMessage,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: feedbackMessage == 'Correct! 🎉'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
