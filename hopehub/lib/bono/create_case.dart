import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hopehub/constants.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class CreateCaseScreen extends StatefulWidget {
  @override
  _CreateCaseScreenState createState() => _CreateCaseScreenState();
}

class _CreateCaseScreenState extends State<CreateCaseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedCategory;
  List<File> selectedFiles = [];
  bool isSubmitting = false;

  final List<String> categories = [
    'Criminal',
    'Family',
    'Corporate',
    'Intellectual Property',
    'Immigration',
    'Labor',
    'Real Estate',
    'Tax',
    'Environmental',
    'Health',
    'Human Rights',
    'Contract',
    'International',
  ];

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> submitCase() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the required fields.')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    String apiUrl = '$BASE_URL/api/bono/cases/create/';
    String? token = await getAuthToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authorization token not found.')),
      );
      setState(() {
        isSubmitting = false;
      });
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = titleController.text;
    request.fields['description'] = descriptionController.text;
    request.fields['category'] = selectedCategory!;

    // Add files to the request
    for (var file in selectedFiles) {
      print('Adding file: ${file.path}');
      try {
        request.files.add(await http.MultipartFile.fromPath(
          'documents', // Ensure this matches the backend field name
          file.path,
          contentType: MediaType('application', 'octet-stream'),
        ));
      } catch (e) {
        print('Error adding file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to attach some files.')),
        );
        setState(() {
          isSubmitting = false;
        });
        return;
      }
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Case created successfully!')),
        );
        // Navigator.pop(context);
      } else {
        print('Server response: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create case.')),
        );
      }
    } catch (error) {
      print('Error creating case: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Case'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) => setState(() {
                  selectedCategory = value;
                }),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: pickFiles,
                child: Text('Select Documents'),
              ),
              SizedBox(height: 8),
              ...selectedFiles.map((file) => Text(file.path.split('/').last)).toList(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: isSubmitting ? null : submitCase,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
                child: isSubmitting
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text('Submit Case'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
