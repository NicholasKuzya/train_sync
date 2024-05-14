import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../token_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RequestsScreen extends StatefulWidget {
  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      String? token = await TokenManager.getToken();
      var url = Uri.parse('http://192.168.0.105:3000/api/trainer/get/requests');
      var response = await http.post(
        url,
        headers: {'authorization': '$token'},
      );
      var data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _requests = List<Map<String, dynamic>>.from(data['requests']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message']),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.network_error_check_connection),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _acceptOrRejectRequest(String studentId, bool accept) async {
    try {
      String? token = await TokenManager.getToken();
      var url = Uri.parse('http://192.168.0.105:3000/api/trainer/request/accept');
      var response = await http.post(
        url,
        headers: {'authorization': '$token', 'Content-Type': 'application/json'},
        body: jsonEncode({'studentId': studentId, 'accept': accept}),
      );
      var data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(accept ? AppLocalizations.of(context)!.accept_message_true : AppLocalizations.of(context)!.accept_message_false),
          backgroundColor: Colors.green,
        ));
        // Обновляем список запросов после принятия или отклонения
        _fetchRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message']),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.network_error_check_connection),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title_requests),
      ),
      body: ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              child: ClipOval(
                child: _requests[index]["avatar"] != null
                    ? Image.network(
                  _requests[index]["avatar"]["src"],
                  fit: BoxFit.cover,
                )
                    : Icon(Icons.person),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: _fetchStudentData(_requests[index]["studentId"] as String),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError || snapshot.data == null) {
                      return Text(AppLocalizations.of(context)!.data_loaded_error);
                    } else {
                      Map<String, dynamic>? studentData = snapshot.data as Map<String, dynamic>?;
                      if (studentData != null) {
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                studentData['fullName'] as String,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () => _showAcceptRejectDialog(true, _requests[index]["studentId"] as String),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => _showAcceptRejectDialog(false, _requests[index]["studentId"] as String),
                            ),
                          ],
                        );
                      } else {
                        return Text(AppLocalizations.of(context)!.data_loaded_error);
                      }
                    }
                  },
                ),
                _buildMessageExpansionTile(_requests[index]['message'] as String),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageExpansionTile(String message) {
    return ExpansionTile(
      title: Text(
        AppLocalizations.of(context)!.requests_message,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            message,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _fetchStudentData(String studentId) async {
    try {
      String? token = await TokenManager.getToken();
      var url = Uri.parse('http://192.168.0.105:3000/api/student/get/$studentId');
      var response = await http.post(
        url,
        headers: {'authorization': '$token'},
      );
      var data = json.decode(response.body);
      if (data['success']) {
        return data['student'];
      } else {
        throw Exception(data['message']);
      }
    } catch (error) {
      throw error;
    }
  }

  void _showAcceptRejectDialog(bool accept, String studentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(accept ? AppLocalizations.of(context)!.accept_true : AppLocalizations.of(context)!.accept_false),
          content: Text(accept ? AppLocalizations.of(context)!.accept_text_true : AppLocalizations.of(context)!.accept_text_false),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _acceptOrRejectRequest(studentId, accept);
              },
              child: Text(accept ? AppLocalizations.of(context)!.accept_true : AppLocalizations.of(context)!.accept_false),
            ),
          ],
        );
      },
    );
  }
}
