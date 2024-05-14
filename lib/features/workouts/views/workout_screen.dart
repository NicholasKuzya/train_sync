import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../token_manager.dart';
import 'package:training_sync/features/exercises/views/exercise_screen.dart';
import 'package:training_sync/features/exercises/views/exercise_set_screen.dart';

class WorkoutAboutScreen extends StatefulWidget {
  final String trainingId;

  const WorkoutAboutScreen({Key? key, required this.trainingId}) : super(key: key);

  @override
  State<WorkoutAboutScreen> createState() => _WorkoutAboutScreenState();
}

class _WorkoutAboutScreenState extends State<WorkoutAboutScreen> {
  Map<String, dynamic> _trainingData = {};

  void _fetchTrainingData() async {
    String? token = await TokenManager.getToken();
    var url = Uri.parse('http://192.168.0.105:3000/api/student/get/training/${widget.trainingId}');
    var response = await http.get(
      url,
      headers: {'authorization': '$token'},
    );
    var responseBody = json.decode(response.body);
    if (responseBody['success']) {
      setState(() {
        _trainingData = responseBody['training'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTrainingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.trainingAbout),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('${_trainingData['description']}'),
            SizedBox(height: 16),
            Text(
              'Exercises:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _trainingData['exercises'].map<Widget>((exercise) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseScreen(exerciseId: exercise['_id']),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${exercise['name']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Description: ${exercise['description']}'),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Exercise Sets:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _trainingData['exerciseSets'].map<Widget>((exerciseSet) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseSetScreen(setId: exerciseSet['_id']),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${exerciseSet['name']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Description: ${exerciseSet['description']}'),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
