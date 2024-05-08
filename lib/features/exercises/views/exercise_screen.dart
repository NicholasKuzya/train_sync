import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../token_manager.dart';
import 'dart:async';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'dart:core';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExerciseScreen extends StatefulWidget {
  final String exerciseId;

  ExerciseScreen({required this.exerciseId});

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  Map<String, dynamic> exercise = {};
  VideoPlayerController? _controller;

  Future<void> _fetchExercise() async {
    String? token = await TokenManager.getToken();

    if (token != null) {
      print(widget.exerciseId);
      final response = await http.get(
        Uri.parse(
            'http://192.168.0.106:3000/api/trainer/exercises/${widget.exerciseId}'),
        headers: {
          'authorization': token,
        },
      );
      final responseBody = json.decode(response.body);
      print(responseBody);

      if (responseBody['success']) {
        setState(() {
          exercise = responseBody['exercise'];
          // Initialize video player controller after exercise data is fetched
          _controller = VideoPlayerController.network(
              'http://192.168.0.106:3000/api/uploads/videos/exercises/${exercise['videoPath']}')
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

  @override
  void initState() {
    super.initState();
    _fetchExercise();
  }

  @override
  Widget build(BuildContext context) {
    // Здесь вы можете вернуть виджет, который будет отображаться на экране упражнения
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.exerciseDetails),
      ),
      body: Column(
        children: [
          if (_controller != null && _controller!.value.isInitialized) ...[
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller!),
                  // Ползунок для перемотки видео
                  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Colors.red,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  // Кнопка для паузы/воспроизведения
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
                        _controller!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Иконка для управления звуком
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
                        _controller!.value.volume == 0
                            ? Icons.volume_off
                            : Icons.volume_up,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(10.0),
                child: Column(
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
            )
          ] else
            Positioned(
              top: 150.0,
              left: 50.0,
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }
}
