import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../token_manager.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  List<Map<String, dynamic>> _students = [];
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchRequestsCount();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      String? token = await TokenManager.getToken();
      var url = Uri.parse('http://192.168.0.106:4000/api/trainer/get/students');
      var response = await http.post(
        url,
        headers: {'authorization': '$token'},
      );
      var data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _students = List<Map<String, dynamic>>.from(data['students']);
        });
      } else {
        // Handle error if needed
        // For example, show a snackbar with the error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message']),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      // Handle network error
      // For example, show a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Network error. Please check your connection.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _fetchRequestsCount() async {
    try {
      String? token = await TokenManager.getToken();
      var url = Uri.parse('http://192.168.0.106:4000/api/trainer/get/requests');
      var response = await http.post(
        url,
        headers: {'authorization': '$token'},
      );
      var data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _requestCount = data['requests'].length;
        });
        print(_requestCount);
      } else {
        // Handle error if needed
        // For example, show a snackbar with the error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message']),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      // Handle network error
      // For example, show a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Network error. Please check your connection.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.request_page),
                onPressed: () {
                  Navigator.pushNamed(context, '/requests'); // Переход на страницу /requests
                },
              ),
              if (_requestCount > 0)
                Positioned(
                  right: 6,
                  top: 4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle, // Указываем форму круга
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '$_requestCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            leading: CircleAvatar(
              radius: 30,
              child: ClipOval(
                child: _students[index]["avatar"] != null
                    ? Image.network(
                  _students[index]["avatar"]["src"],
                  fit: BoxFit.cover,
                )
                    : Icon(Icons.person),
              ),
            ),
            title: Text(_students[index]['fullName']),
            onTap: () {
              // Action when student is tapped
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.chat),
                  onPressed: () {
                    // Action when chat icon is pressed
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    // Action when settings icon is pressed
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
