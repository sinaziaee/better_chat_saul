import 'dart:io';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String? text; // Text for messages
  final bool isUser;
  final File? imageFile; // Optional image file for file messages

  const MessageBubble({
    this.text,
    required this.isUser,
    this.imageFile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: imageFile == null ? const EdgeInsets.all(12) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
          ),
        ),
        child: imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            imageFile!,
            height: 150,
            width: 150,
            fit: BoxFit.cover,
          ),
        )
            : Text(
          text ?? "",
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}
