import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../token_manager.dart';
import 'exercise_screen.dart';
import 'package:training_sync/admob_service.dart';
// AdBanner(),

class ExerciseSetScreen extends StatefulWidget {
  final String setId;

  ExerciseSetScreen({required this.setId});

  @override
  _ExerciseSetScreenState createState() => _ExerciseSetScreenState();
}

class _ExerciseSetScreenState extends State<ExerciseSetScreen> {
  Map<String, dynamic> set = {};
  List<dynamic> allExercises = [];
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  Future<void> _fetchSet() async {
    String? token = await TokenManager.getToken();
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://192.168.0.105:3000/api/trainer/set/${widget.setId}'),
        headers: {
          'authorization': token,
        },
      );
      final responseBody = json.decode(response.body);
      if (responseBody['success']) {
        setState(() {
          set = responseBody['exerciseSet'];
          _nameController = TextEditingController(text: set['name']);
          _descriptionController = TextEditingController(text: set['description']);
        });
        _fetchAllExercises(); // Fetch all exercises after fetching the set
      } else {
        throw Exception('Failed to load exercise set');
      }
    } else {
      throw Exception('Token is null');
    }
  }

  Future<void> _fetchAllExercises() async {
    String? token = await TokenManager.getToken();
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://192.168.0.105:3000/api/trainer/exercises'),
        headers: {
          'authorization': token,
        },
      );
      final responseBody = json.decode(response.body);
      if (responseBody['success']) {
        setState(() {
          allExercises = responseBody['exercises'];
        });
      } else {
        throw Exception('Failed to load exercises');
      }
    } else {
      throw Exception('Token is null');
    }
  }

  Future<void> _updateSet() async {
    if (_formKey.currentState!.validate()) {
      String? token = await TokenManager.getToken();
      if (token != null) {
        final response = await http.put(
          Uri.parse('http://192.168.0.105:3000/api/trainer/set/${widget.setId}'),
          headers: {
            'Content-Type': 'application/json',
            'authorization': token,
          },
          body: json.encode({
            'name': _nameController.text,
            'description': _descriptionController.text,
            'exercises': set['exercises'], // Include updated exercises
          }),
        );

        final responseBody = json.decode(response.body);

        if (responseBody['success']) {
          setState(() {
            set['name'] = _nameController.text;
            set['description'] = _descriptionController.text;
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Set updated successfully')));
        } else {
          throw Exception('Failed to update set');
        }
      } else {
        throw Exception('Token is null');
      }
    }
  }

  Future<void> _deleteSet() async {
    String? token = await TokenManager.getToken();
    if (token != null) {
      final response = await http.delete(
        Uri.parse('http://192.168.0.105:3000/api/trainer/set/${widget.setId}'),
        headers: {
          'authorization': token,
        },
      );

      final responseBody = json.decode(response.body);

      if (responseBody['success']) {
        Navigator.of(context).pop();  // Close the screen after successful deletion
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Set deleted successfully')));
      } else {
        throw Exception('Failed to delete set');
      }
    } else {
      throw Exception('Token is null');
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this set?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
                _deleteSet();  // Call the delete function
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
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
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateSet();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (set['name'] != '' && set['name'] != null && set.isNotEmpty) ...[
                    _isEditing
                        ? Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Set Name',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the set name';
                              }
                              return null;
                            },
                            maxLines: 3,
                            minLines: 1,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the description';
                              }
                              return null;
                            },
                            maxLines: 10,
                            minLines: 1,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Select Exercises:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          _buildExerciseSelection(),
                        ],
                      ),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Set Name: ${set['name']}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Description: ${set['description']}',
                          style: TextStyle(fontSize: 16.0),
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ExerciseScreen(exerciseId: exercise['_id'])),
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
            ),
          ),
          AdBanner(), // Рекламный баннер всегда виден внизу
        ],
      ),
    );
  }

  Widget _buildExerciseSelection() {
    if (allExercises.isEmpty) {
      return CircularProgressIndicator();
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: allExercises.length,
      itemBuilder: (BuildContext context, int index) {
        var exercise = allExercises[index];
        bool isSelected = set['exercises'].any((e) => e['_id'] == exercise['_id']);
        return CheckboxListTile(
          title: Text(exercise['name']),
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                set['exercises'].add(exercise);
              } else {
                set['exercises'].removeWhere((e) => e['_id'] == exercise['_id']);
              }
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
