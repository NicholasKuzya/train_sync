import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoEditorScreen extends StatefulWidget {
  final String videoPath;

  VideoEditorScreen({required this.videoPath});

  @override
  _VideoEditorScreenState createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Editor'),
      ),
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : Container(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.crop),
                    onPressed: () {
                      // Обработка нажатия кнопки обрезки
                    },
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: Icon(Icons.music_note),
                    onPressed: () {
                      // Обработка нажатия кнопки добавления музыки
                    },
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: Icon(Icons.text_fields),
                    onPressed: () {
                      // Обработка нажатия кнопки добавления текста
                    },
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: Icon(Icons.brush),
                    onPressed: () {
                      // Обработка нажатия кнопки добавления фильтров
                    },
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Обработка нажатия кнопки сохранения
        },
        child: Icon(Icons.save),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}