import 'package:app2/features/video_editor/views/video_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class GalleryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
      ),
      body: Center(
        child: Text('Gallery content goes here'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Открытие меню при нажатии на синюю кнопку
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              MediaQuery.of(context).size.width - 50.0,
              MediaQuery.of(context).size.height - 120.0,
              0.0,
              0.0,
            ),
            items: [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.playlist_add),
                  title: Text('Create a set'),
                ),
                onTap: () {
                  // Обработка выбора "Create a set"
                },
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.video_library),
                  title: Text('Add video'),
                ),
                onTap: () async {
                  // Обработка выбора "Add video"
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['mp4', 'mov', 'avi'], // Разрешаем только видеофайлы
                  );
                  if (result != null) {
                    // Обработка выбранных файлов
                    for (var file in result.files) {
                      print('Выбранный файл: ${file.path}');
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoEditorScreen(videoPath: file.path!),
                        ),
                      );
                    }
                  } else {
                    // Пользователь отменил выбор файла
                    print('Выбор файла отменен');
                  }
                },
              ),
            ],
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
        elevation: 2.0, // Добавляем небольшую тень
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Делаем круглой полностью
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Располагаем чуть выше
    );
  }
}


