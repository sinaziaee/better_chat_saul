import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;

import '../constants.dart'; // For API calls

class QuizScreen extends StatefulWidget {
  final String token;
  final int id;

  const QuizScreen({Key? key, required this.token, required this.id})
      : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, dynamic>? quizData; // Store the quiz data
  bool isLoading = true;
  bool showFeedback = false;
  String feedbackMessage = '';
  List options = [];

  @override
  void initState() {
    super.initState();
    fetchQuiz();
  }

  Future<void> fetchQuiz() async {
    // String apiUrl = '$BASE_URL/api/game/quizzes/${widget.id}/';
    String apiUrl = '$BASE_URL/api/game/quizzes/4/';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',        },
      );

      if (response.statusCode == 200) {
        setState(() {
          quizData = json.decode(response.body);
          // print(quizData);
          List tempList = [quizData?['option1'], quizData?['option2'], quizData?['option3'], quizData?['option4']];
          for (String item in tempList) {
            if (item != null) {
              options.add(item);
            }
          }
          print('+++++++++++++++++++');
          print(options);
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
      print(quizData!['answer']);
      int correctOption = quizData!['answer'];
      setState(() {
        showFeedback = true;
        feedbackMessage = selectedOption == correctOption
            ? 'Correct! 🎉'
            : 'Wrong! Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : quizData == null
          ? Center(child: Text('No quiz available.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quizData!['question'],
              style: TextStyle(
                  fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...List.generate(options.length, (index) {
              final option = options[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => checkAnswer(index),
                  child: Text(option),
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
    );
  }
}