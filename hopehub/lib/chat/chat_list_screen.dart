import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'chat_screen.dart';

class ChatSessionsPage extends StatefulWidget {
  const ChatSessionsPage({Key? key}) : super(key: key);

  @override
  State<ChatSessionsPage> createState() => _ChatSessionsPageState();
}

class _ChatSessionsPageState extends State<ChatSessionsPage> {
  List<dynamic> chatSessions = []; // Store chat sessions here
  bool isLoading = true; // For loading indicator

  String? token; // To store auth token

  @override
  void initState() {
    super.initState();
    fetchChatSessions(); // Fetch chat sessions when page loads
  }

  // Function to get auth token from shared preferences
  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Function to fetch chat sessions from Django REST API
  Future<void> fetchChatSessions() async {
    try {
      token = await getAuthToken(); // Get token from shared preferences
      if (token == null) {
        throw Exception('Authorization token not found');
      }

      final response = await http.get(
        Uri.parse('$BASE_URL/api/chat/chat_sessions/'),
        headers: {
          'Authorization': 'Bearer $token', // Include token in headers
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          chatSessions = jsonDecode(response.body);
          isLoading = false; // Stop loading
        });
      } else {
        throw Exception('Failed to load chat sessions');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading even on error
      });
      print("Error fetching chat sessions: $e");
    }
  }

  Future<Map<String, dynamic>?> createNewChatSession(
      BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        throw Exception('Authorization token not found');
      }

      final response = await http.post(
        Uri.parse('$BASE_URL/api/chat/chat_sessions/create/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // "session_name": "New Session"
          "session_name": "New Session"
        }), // Optional: Prompt user for session name
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create new chat session');
      }
    } catch (e) {
      print('Error creating chat session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating chat session: $e')),
      );
      return null;
    }
  }

  Future<void> deleteChatSession(int sessionId) async {
    try {
      if (token == null) {
        token = await getAuthToken();
        if (token == null) {
          throw Exception('Authorization token not found');
        }
      }

      final response = await http.delete(
        Uri.parse('$BASE_URL/api/chat/chat_sessions/$sessionId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        // Successfully deleted, update the UI
        setState(() {
          chatSessions.removeWhere((session) => session['id'] == sessionId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat session deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete chat session');
      }
    } catch (e) {
      print('Error deleting chat session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting chat session: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Available Chat Sessions')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[100],
        onPressed: () async {
          final newSession = await createNewChatSession(context);
          if (newSession != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                    sessionId: newSession['id'], token: token ?? '-1'),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator()) // Show loading indicator
          : chatSessions.isEmpty
          ? const Center(
          child: Text('No chat sessions found')) // Show if no data
          : ListView.builder(
        itemCount: chatSessions.length,
        itemBuilder: (context, index) {
          final session = chatSessions[index];
          String name =
              '${session['id']}, ${session['session_name'] ?? 'Unnamed Session'}';
          DateTime time = DateTime.parse(session['created_at']);
          String formattedDate =
              '${time.year}-${time.month}-${time.day}, ${time.hour}:${time.minute}';

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 10.0, vertical: 5.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15.0),
                title: Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  'Created at: $formattedDate',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.blueGrey),
                      onPressed: () {
                        // Confirm deletion
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Chat Session'),
                              content: const Text('Are you sure you want to delete this chat session?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop(); // Close the dialog
                                    await deleteChatSession(session['id']);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    // const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                onTap: () {
                  // Navigate to the specific chat session
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        print('Chat session ID: ${session['id']}');
                        return ChatScreen(
                          sessionId: session['id'],
                          token: token ?? '-1',
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
