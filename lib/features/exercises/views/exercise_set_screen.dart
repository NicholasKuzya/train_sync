import 'package:training_sync/features/exercises/views/exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../token_manager.dart';

class ExerciseSetScreen extends StatefulWidget {
  final String setId;

  ExerciseSetScreen({required this.setId});

  @override
  _ExerciseSetScreenState createState() => _ExerciseSetScreenState();
}

class _ExerciseSetScreenState extends State<ExerciseSetScreen> {
  Map<String, dynamic> set = {};

  Future<void> _fetchSet() async {
    String? token = await TokenManager.getToken();
    print(token);
    if (token != null) {
      print(widget.setId);
      final response = await http.get(
        Uri.parse(
            'http://192.168.0.105:3000/api/trainer/set/${widget
                .setId}'),
        headers: {
          'authorization': token,
        },
      );
      final responseBody = json.decode(response.body);
      print(responseBody);
      if (responseBody['success']) {
        setState(() {
          set = responseBody['exerciseSet'];
        });
      } else {
        throw Exception('Failed to load exercise');
      }
    } else {
      throw Exception('Token is null');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Set Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (set['name'] != '' && set['name'] != null && set.isNotEmpty) ...[
                  Text(
                    'Set Name: ${set['name']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Description: ${set['description']}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 40.0),
                  Text(
                    'Exercises:',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: set['exercises'].length,
                    itemBuilder: (BuildContext context, int index) {
                      var exercise = set['exercises'][index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to the exercise details page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ExerciseScreen(exerciseId: exercise['_id'])),
                          );
                        },
                        child: Card(
                          elevation: 5.0,
                          margin: EdgeInsets.only(bottom: 10.0),
                          child: ListTile(
                            title: Text(
                              exercise['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            if (set['name'] == '' || set['name'] == null && set.isNotEmpty) ...[
              // Display a circular progress indicator if data is still loading
              Positioned(
                top: 150.0,
                left: 50.0,
                child: CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}