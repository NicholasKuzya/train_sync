import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../token_manager.dart';
import 'package:training_sync/upload_manager.dart';

class VideoEditorScreen extends StatefulWidget {
  final String videoPath;

  VideoEditorScreen({required this.videoPath});

  @override
  _VideoEditorScreenState createState() => _VideoEditorScreenState(
    muscleCategoryController: TextEditingController(),
    exerciseNameController: TextEditingController(),
    exerciseDescriptionController: TextEditingController(),
  );
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  late VideoPlayerController _controller;
  late TextEditingController muscleCategoryController;
  late TextEditingController exerciseNameController;
  late TextEditingController exerciseDescriptionController;
  double _videoPosition = 0.0;

  _VideoEditorScreenState({
    required this.muscleCategoryController,
    required this.exerciseNameController,
    required this.exerciseDescriptionController,
  });

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
      });

    _controller.addListener(() {
      setState(() {
        _videoPosition = _controller.value.position.inMilliseconds /
            _controller.value.duration.inMilliseconds;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    muscleCategoryController.dispose();
    exerciseNameController.dispose();
    exerciseDescriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UploadManager(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Video Editor'),
          actions: [
            IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _showEditMessage(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.forward),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoViewScreen(
                      videoPath: widget.videoPath,
                      muscleCategoryController: muscleCategoryController,
                      exerciseNameController: exerciseNameController,
                      exerciseDescriptionController: exerciseDescriptionController,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: _controller.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
                    : Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Редактирование"),
          content: Text("Мы скоро добавим эту функцию в обновлении!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

class VideoViewScreen extends StatefulWidget {
  final String videoPath;
  final TextEditingController muscleCategoryController;
  final TextEditingController exerciseNameController;
  final TextEditingController exerciseDescriptionController;

  VideoViewScreen({
    required this.videoPath,
    required this.muscleCategoryController,
    required this.exerciseNameController,
    required this.exerciseDescriptionController,
  });

  @override
  _VideoViewScreenState createState() => _VideoViewScreenState();
}

class _VideoViewScreenState extends State<VideoViewScreen> {
  @override
  Widget build(BuildContext context) {
    final uploadManager = Provider.of<UploadManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Video settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayer(VideoPlayerController.network(widget.videoPath)),
            ),
            SizedBox(height: 20),
            if (uploadManager.isUploading)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    LinearPercentIndicator(
                      lineHeight: 8.0,
                      percent: uploadManager.uploadProgress,
                      backgroundColor: Colors.grey[200],
                      progressColor: Colors.blue,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${(uploadManager.uploadProgress * 100).toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: widget.muscleCategoryController,
                    decoration: InputDecoration(labelText: 'Muscle category name'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: widget.exerciseNameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    maxLines: 2,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: widget.exerciseDescriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 5,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _sendToServer(
                        widget.muscleCategoryController.text,
                        widget.exerciseNameController.text,
                        widget.exerciseDescriptionController.text,
                        context,
                        uploadManager,
                      );
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendToServer(
      String muscleCategory,
      String name,
      String description,
      BuildContext context,
      UploadManager uploadManager,
      ) async {
    String? token = await TokenManager.getToken();
    if (token != null) {
      var categoryResponse = await _createMuscleCategory(token, muscleCategory);
      if (categoryResponse['success']) {
        String categoryId = categoryResponse['muscleCategoryId'];
        var exerciseResponse = await uploadManager.uploadFile(
            token, widget.videoPath, categoryId, name, description);
        if (exerciseResponse['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exercise uploaded successfully')),
          );
          Navigator.pushReplacementNamed(context, '/gallery');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload exercise')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create muscle category')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token is null')),
      );
    }
  }

  Future<Map<String, dynamic>> _createMuscleCategory(String token, String name) async {
    var headers = {'authorization': token, 'Content-Type': 'application/json'};
    var body = json.encode({'name': name});

    var response = await http.post(
      Uri.parse('https://training-sync.com/api/trainer/muscle-categories'),
      headers: headers,
      body: body,
    );
    print(json.decode(response.body));
    return json.decode(response.body);
  }
}
