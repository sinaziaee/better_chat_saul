import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hopehub/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CaseDetailScreen extends StatefulWidget {
  final int caseId;

  CaseDetailScreen({required this.caseId});

  @override
  _CaseDetailScreenState createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  Map<String, dynamic>? caseDetail;
  bool isLoading = true;
  bool isSubmitting = false;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCaseDetails();
  }

  Future<String?> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchCaseDetails() async {
    String apiUrl = '$BASE_URL/api/bono/cases/${widget.caseId}/';

    try {
      final token = await getAuthToken();
      if (token == null) {
        throw Exception('Authorization token not found');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          caseDetail = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load case details');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching case details: $error');
    }
  }

  Future<void> downloadDocument(String documentUrl) async {
    try {
      final response = await http.get(Uri.parse(documentUrl));
      if (response.statusCode == 200) {
        // Handle the file download logic here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document downloaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download document')),
        );
      }
    } catch (error) {
      print('Error downloading document: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while downloading')),
      );
    }
  }

  Future<void> sendApplication() async {
    String apiUrl = '$BASE_URL/api/bono/applications/create/';
    setState(() {
      isSubmitting = true;
    });

    try {
      final token = await getAuthToken();
      if (token == null) {
        throw Exception('Authorization token not found');
      }
      print(token);
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'case': widget.caseId,
          'message': messageController.text,
          'price': double.tryParse(priceController.text) ?? 0.0,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send application')),
        );
      }
    } catch (error) {
      print('Error sending application: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
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
        title: Text('Case Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : caseDetail == null
          ? Center(child: Text('Failed to load case details.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caseDetail!['title'] ?? 'No Title',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Status: ${caseDetail!['status'] ?? 'Unknown'}',
                style: TextStyle(
                  fontSize: 16,
                  color: caseDetail!['status'] == 'Open'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Category: ${caseDetail!['category'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Description:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                caseDetail!['description'] ?? 'No Description',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Created At: ${caseDetail!['created_at'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (caseDetail!['documents'] != null &&
                  caseDetail!['documents'].isNotEmpty) ...[
                SizedBox(height: 24),
                Text(
                  'Documents:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...caseDetail!['documents'].map<Widget>((doc) {
                  return TextButton(
                    onPressed: () => downloadDocument(doc['file']),
                    child: Text(doc['name']),
                  );
                }).toList(),
              ],
              SizedBox(height: 24),
              Text(
                'Send Application:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Message',
                  hintText: 'Write your application message...',
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Price (Optional)',
                  hintText: 'Enter your proposed price...',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: isSubmitting ? null : sendApplication,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Colors.blue,
                ),
                child: isSubmitting
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white),
                )
                    : Text(
                  'Send Application',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
