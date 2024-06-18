import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../token_manager.dart';
import 'dart:async';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'dart:core';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:training_sync/admob_service.dart';

class ExerciseScreen extends StatefulWidget {
  final String exerciseId;

  ExerciseScreen({required this.exerciseId});

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  Map<String, dynamic> exercise = {};
  VideoPlayerController? _controller;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  Future<void> _fetchExercise() async {
    String? token = await TokenManager.getToken();

    if (token != null) {
      final response = await http.get(
        Uri.parse(
            'https://training-sync.com/api/trainer/exercises/${widget.exerciseId}'),
        headers: {
          'authorization': token,
        },
      );
      final responseBody = json.decode(response.body);

      if (responseBody['success']) {
        setState(() {
          exercise = responseBody['exercise'];
          _nameController = TextEditingController(text: exercise['name']);
          _descriptionController = TextEditingController(text: exercise['description']);
          _controller = VideoPlayerController.network(
              'https://training-sync.com/api/uploads/videos/exercises/${exercise['videoPath']}')
            ..initialize().then((_) {
              setState(() {});
            });
        });
      } else {
        throw Exception('Failed to load exercise');
      }
    } else {
      throw Exception('Token is null');
    }
  }

  Future<void> _updateExercise() async {
    if (_formKey.currentState!.validate()) {
      String? token = await TokenManager.getToken();

      if (token != null) {
        final response = await http.put(
          Uri.parse('https://training-sync.com/api/trainer/exercises/${widget.exerciseId}'),
          headers: {
            'Content-Type': 'application/json',
            'authorization': token,
          },
          body: json.encode({
            'name': _nameController.text,
            'description': _descriptionController.text,
          }),
        );

        final responseBody = json.decode(response.body);

        if (responseBody['success']) {
          setState(() {
            exercise['name'] = _nameController.text;
            exercise['description'] = _descriptionController.text;
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exercise updated successfully')));
        } else {
          throw Exception('Failed to update exercise');
        }
      } else {
        throw Exception('Token is null');
      }
    }
  }

  Future<void> _deleteExercise() async {
    String? token = await TokenManager.getToken();

    if (token != null) {
      final response = await http.delete(
        Uri.parse('https://training-sync.com/api/trainer/exercises/${widget.exerciseId}'),
        headers: {
          'authorization': token,
        },
      );

      final responseBody = json.decode(response.body);
      print(responseBody);

      if (responseBody['success']) {
        Navigator.of(context).pop();  // Close the screen after successful deletion
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exercise deleted successfully')));
      } else {
        throw Exception('Failed to delete exercise');
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
          title: Text('${AppLocalizations.of(context)!.confirm}?'),
          content: Text(AppLocalizations.of(context)!.successDelete),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
                _deleteExercise();  // Call the delete function
              },
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchExercise();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.exerciseDetails),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateExercise();
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
      body: _controller == null || !_controller!.value.isInitialized
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_controller!),
                VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.white,
                  ),
                ),
                Positioned(
                  bottom: 10.0,
                  left: 10.0,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (_controller!.value.isPlaying) {
                          _controller!.pause();
                        } else {
                          _controller!.play();
                        }
                      });
                    },
                    icon: Icon(
                      _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10.0,
                  right: 10.0,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _controller!.value.volume == 0
                            ? _controller!.setVolume(1)
                            : _controller!.setVolume(0);
                      });
                    },
                    icon: Icon(
                      _controller!.value.volume == 0 ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: _isEditing
                    ? Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        maxLines: 3,
                        controller: _nameController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.exerciseName),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the exercise name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        maxLines: 10,
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.exerciseDescription),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the exercise description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                )
                    : Column(
                  children: [
                    Text(
                      '${exercise['name']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text('${exercise['description']}')
                  ],
                ),
              ),
            ),
          ),
          AdBanner(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
