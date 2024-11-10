import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http; // Import http package

import '../constants.dart';
import 'components/message_bubble.dart';
import 'components/message_input.dart';

class ChatScreen extends StatefulWidget {
  final int sessionId;
  final String token;
  const ChatScreen({required this.sessionId, super.key, required this.token});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = []; // Allow dynamic types for messages
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel channel;
  final ScrollController _scrollController = ScrollController(); // Scroll controller for ListView

  @override
  void initState() {
    super.initState();

    // Set up the WebSocket channel with your backend
    channel = WebSocketChannel.connect(
      Uri.parse('ws://$BASE_URL_IP/ws/chat/${widget.sessionId}/'), // Replace with your backend URL
    );

    // Listen for incoming messages from the WebSocket
    channel.stream.listen((data) {
      final message = jsonDecode(data);
      setState(() {
        messages.add({"sender": message['role'], "text": message['message']});
        print("Last message added: ${messages.last}"); // Print the last message
      });
      _scrollToBottom(isIncoming: true); // Ensure scroll for bot messages
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      // Send message to WebSocket
      channel.sink.add(jsonEncode({"message": _controller.text}));

      setState(() {
        messages.add({"sender": "user", "text": _controller.text});
        print("Last message added: ${messages.last}"); // Print the last message
      });

      _controller.clear();
      _scrollToBottom(); // Scroll to the bottom when a new message is sent
    }
  }

  Future<void> _uploadFile() async {
    // Allow user to pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      // Determine file type
      final isImage = ['png', 'jpg', 'jpeg'].contains(result.files.single.extension?.toLowerCase());
      final fileType = isImage ? 'image' : 'document';

      // Upload the file via HTTP POST
      try {
        // Create a multipart request
        var request = http.MultipartRequest('POST', Uri.parse('$BASE_URL/api/chat/upload_file/'));
        request.fields['session_id'] = widget.sessionId.toString();
        request.fields['file_type'] = fileType;
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        request.headers['Authorization'] = 'Bearer ${widget.token}';

        // Send the request
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success') {
            final fileId = responseData['file_id'];

            // Notify the WebSocket server to process the file
            channel.sink.add(jsonEncode({
              "file_id": fileId,
              "file_type": fileType,
            }));

            // Add the file to the UI
            setState(() {
              messages.add({
                "sender": "user",
                "file": file,
                "isImage": isImage,
                "name": fileName,
              });
              print("Last message added: ${messages.last}");
            });

            _scrollToBottom();
          } else {
            // Handle error from server
            print("Error from server: ${responseData['message']}");
          }
        } else {
          // Handle HTTP error
          print("HTTP error: ${response.statusCode}");
        }
      } catch (e) {
        // Handle exception
        print("Exception during file upload: $e");
      }
    }
  }

  void _scrollToBottom({bool isIncoming = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isIncoming) {
        Future.delayed(const Duration(milliseconds: 50), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close(status.normalClosure); // Close with a valid close code
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Session ${widget.sessionId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Attach the ScrollController
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message["sender"] == "user";

                if (message.containsKey("file")) {
                  // File message
                  return MessageBubble(
                    isUser: isUser,
                    text: message["isImage"] == true
                        ? null
                        : "Document: ${message['name']}",
                    imageFile: message["isImage"] == true ? message["file"] : null,
                  );
                } else {
                  // Text message
                  return MessageBubble(
                    isUser: isUser,
                    text: message["text"],
                  );
                }
              },
            ),
          ),
          MessageInput(
            controller: _controller,
            onSend: _sendMessage,
            onAttach: _uploadFile, // Add file upload handler
          ),
        ],
      ),
    );
  }
}
