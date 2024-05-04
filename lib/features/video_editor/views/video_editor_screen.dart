import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../token_manager.dart';

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
  double _videoPosition = 0.0; // Define _videoPosition here

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
    return Scaffold(
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
              // Переходим на экран просмотра и отправки видео
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoViewScreen(
                    videoPath: widget.videoPath,
                    muscleCategoryController: muscleCategoryController,
                    exerciseNameController: exerciseNameController,
                    exerciseDescriptionController:
                        exerciseDescriptionController,
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
            child: Stack(
              children: [
                Positioned.fill(
                  child: VideoPlayer(_controller),
                ),
                // Здесь находится ваша таймлиния и другие элементы редактора,
                // которые были удалены или закомментированы.
              ],
            ),
          ),
        ],
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

class VideoViewScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video settings'),
      ),
      body: SingleChildScrollView(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Отображение видео в альбомной форме
            AspectRatio(
              aspectRatio: 16 / 9, // Примерное соотношение сторон
              child: VideoPlayer(VideoPlayerController.network(videoPath)),
            ),
            SizedBox(height: 20),
            // Форма для ввода названия, описания и кнопки отправки на сервер
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: muscleCategoryController,
                    decoration:
                    InputDecoration(labelText: 'Muscle category name'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: exerciseNameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    maxLines: 2,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: exerciseDescriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 5,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Отправка на сервер
                      _sendToServer(
                        muscleCategoryController.text,
                        exerciseNameController.text,
                        exerciseDescriptionController.text,
                        context,
                      );
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  Future<void> _sendToServer(String muscleCategory, String name,
      String description, BuildContext context) async {
    String? token = await TokenManager.getToken();
    if (token != null) {
      showDialog(
        context: context,
        barrierDismissible: false, // Запрещаем закрытие диалога нажатием за его пределами
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(), // Индикатор загрузки
                  SizedBox(height: 20),
                  Text('Uploading...'), // Текст "Загрузка..."
                ],
              ),
            ),
          );
        },
      );

      // Отправляем запрос на создание новой категории мышц
      var categoryResponse = await _createMuscleCategory(token, muscleCategory);
      if (categoryResponse['success']) {
        String categoryId = categoryResponse['muscleCategoryId'];
        var exerciseResponse = await _createExercise(
            token, categoryId, name, description, context);
        Navigator.pop(context); // Закрываем диалог после завершения загрузки
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
        Navigator.pop(context); // Закрываем диалог после завершения загрузки
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

  // Move this method inside the VideoViewScreen class
  Future<Map<String, dynamic>> _createMuscleCategory(
      String token, String name) async {
    var headers = {'authorization': token, 'Content-Type': 'application/json'};
    var body = json.encode({'name': name});

    var response = await http.post(
      Uri.parse('http://192.168.0.105:4000/api/trainer/muscle-categories'),
      headers: headers,
      body: body,
    );
    print(json.decode(response.body));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> _createExercise(
      String token,
      String categoryId,
      String name,
      String description,
      BuildContext context,
      ) async {
    var headers = {'authorization': token};

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.0.105:4000/api/trainer/exercises'),
    );
    request.headers.addAll(headers);

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['muscleCategoryId'] = categoryId;

    request.files.add(await http.MultipartFile.fromPath('video', videoPath));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return json.decode(response.body);
  }
}
