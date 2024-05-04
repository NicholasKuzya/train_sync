import 'package:training_sync/features/exercises/views/exercise_screen.dart';
import 'package:training_sync/features/exercises/views/exercise_set_screen.dart';
import 'package:flutter/material.dart';
import 'package:training_sync/features/video_editor/views/video_editor_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../token_manager.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategorySelector extends StatefulWidget {
  final List<dynamic> categories;
  final ValueChanged<String> onChanged;

  const CategorySelector({
    Key? key,
    required this.categories,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'all'; // По умолчанию выбрана категория 'all'
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      value: _selectedCategory,
      onChanged: (newValue) {
        setState(() {
          _selectedCategory = newValue as String; // Явное приведение типа
          widget.onChanged(newValue as String); // Явное приведение типа
        });
      },
      items: [
        DropdownMenuItem(
          value: 'all',
          child: Text('All'),
        ),
        for (var category in widget.categories)
          DropdownMenuItem(
            value: category['_id'],
            child: Text(category['name']),
          ),
      ],
    );
  }
}

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<dynamic> exercises = []; // Список упражнений
  List<dynamic> categories = [];
  List<dynamic> sets = [];
  List<dynamic> selectedExercises = [];
  String? _token;

  // Метод для асинхронного получения токена
  Future<String?> _getToken() async {
    // Здесь может быть ваша логика для получения токена
    return TokenManager.getToken();
  }

  Future<File> _loadThumbnail(String? videoPath) async {
    if (videoPath == null) {
      throw ArgumentError('videoPath cannot be null');
    }
    String tempDir = (await getTemporaryDirectory()).path;
    print('Temporary directory path: $tempDir');
    String thumbnailPath = '$tempDir/thumbnail.jpg';
    await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: thumbnailPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      quality: 25,
    );
    return File(thumbnailPath);
  }

  // Метод для загрузки данных об упражнениях с сервера
  Future<void> _fetchExercises(String token, {String? category}) async {
    final Uri url = category != null
        ? Uri.parse(
            'http://192.168.0.105:4000/api/trainer/exercises?categoryId=$category')
        : Uri.parse('http://192.168.0.105:4000/api/trainer/exercises');

    final response = await http.get(
      url,
      headers: {
        'authorization': token,
      },
    );
    final responseBody = json.decode(response.body);
    print(responseBody);
    if (responseBody['success']) {
      setState(() {
        exercises = responseBody['exercises'];
      });
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  Future<void> _fetchSets(String token, {String? category}) async {
    final Uri url = category != null
        ? Uri.parse(
            'http://192.168.0.105:4000/api/trainer/set?categoryId=$category')
        : Uri.parse('http://192.168.0.105:4000/api/trainer/set');

    final response = await http.get(
      url,
      headers: {
        'authorization': token,
      },
    );
    final responseBody = json.decode(response.body);
    print(responseBody);
    if (responseBody['success']) {
      setState(() {
        sets = responseBody['exerciseSets'];
      });
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  // Метод для загрузки данных об категориях с сервера
  Future<void> _fetchCategories(String token) async {
    final response = await http.get(
      Uri.parse('http://192.168.0.105:4000/api/trainer/muscle-categories'),
      headers: {
        'authorization': token, // Добавляем токен в заголовок
      },
    );
    final responseBody = json.decode(response.body);
    print(responseBody);
    if (responseBody['success']) {
      setState(() {
        categories = (responseBody['muscleCategories'] as List<dynamic>)
            .cast<Map<String, dynamic>>(); // Обновляем список упражнений
      });
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  @override
  void initState() {
    super.initState();
    _getToken().then((token) {
      if (token != null) {
        setState(() {
          _token = token;
        });
        _fetchExercises(token);
        _fetchCategories(token);
        _fetchSets(token); // Загружаем упражнения при инициализации виджета
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2, // Количество вкладок (Упражнения и Сеты)
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.title_gallery),
            bottom: TabBar(
              tabs: [
                Tab(text: AppLocalizations.of(context)!.exercises),
                // Вкладка для упражнений
                Tab(text: AppLocalizations.of(context)!.sets),
                // Вкладка для сетов
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Column(
                children: [
                  CategorySelector(
                    categories: categories,
                    onChanged: (selectedCategory) {
                      if (selectedCategory == 'all') {
                        _fetchExercises(_token!);
                      } else {
                        _fetchExercises(_token!, category: selectedCategory);
                      }
                      // print('${AppLocalizations.of(context)!.selectedCategoryMessage} $selectedCategory');
                    },
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseScreen(
                                  exerciseId: '${exercise['_id']}',
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Container(
                                    height: 200,
                                    child: FutureBuilder<File>(
                                      future: _loadThumbnail(
                                        'http://192.168.0.105:4000/api/uploads/videos/exercises/${exercise['videoPath'] ?? ''}',
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          return Image.file(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise['name'],
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          exercise['description'],
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  CategorySelector(
                    categories: categories,
                    onChanged: (selectedCategory) {
                      if (selectedCategory == 'all') {
                        _fetchSets(_token!);
                      } else {
                        _fetchSets(_token!, category: selectedCategory);
                      }
                      // print('${AppLocalizations.of(context)!.selectedCategoryMessage} $selectedCategory');
                    },
                  ),
                  Expanded(
                    child: GridView.builder(
                      // GridView для отображения сетов
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: sets.length, // Количество сетов
                      itemBuilder: (context, index) {
                        final set = sets[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseSetScreen(
                                  setId: '${set['_id']}',
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Здесь можно разместить виджеты для отображения информации о сете, например, его название и описание
                                // Например:
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    set['name'], // Название сета
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    set['description'], // Описание сета
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
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
                      title: Text(AppLocalizations.of(context)!.createSet),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectExercisesScreen(
                            exercises: exercises,
                            selectedExercises: selectedExercises,
                            // Pass selectedExercises here
                            onSelect: (exercises) {
                              setState(() {
                                selectedExercises = exercises;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.video_library),
                      title: Text(AppLocalizations.of(context)!.addExercise),
                    ),
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: [
                          'mp4',
                          'mov',
                          'avi',
                        ],
                      );
                      if (result != null) {
                        for (var file in result.files) {
                          // print('${AppLocalizations.of(context)!.selectedFileMessage} ${file.path}');
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoEditorScreen(
                                videoPath: file.path!,
                              ),
                            ),
                          );
                        }
                      } else {
                        // print(AppLocalizations.of(context)!.fileSelectionCanceled);
                      }
                    },
                  ),
                ],
              );
            },
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.blue,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ));
  }
}

class SelectExercisesScreen extends StatefulWidget {
  final List<dynamic> exercises;
  final List<dynamic> selectedExercises;
  final Function(List<dynamic>) onSelect;

  SelectExercisesScreen({
    required this.exercises,
    required this.selectedExercises,
    required this.onSelect,
  });

  @override
  _SelectExercisesScreenState createState() => _SelectExercisesScreenState();
}

class _SelectExercisesScreenState extends State<SelectExercisesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectExercises),
      ),
      body: ListView.builder(
        itemCount: widget.exercises.length,
        itemBuilder: (context, index) {
          final exercise = widget.exercises[index];
          final bool isSelected = widget.selectedExercises.contains(exercise);
          return ListTile(
            title: Text(exercise['name']),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    widget.selectedExercises.add(exercise);
                  } else {
                    widget.selectedExercises.remove(exercise);
                  }
                });
                widget.onSelect(widget.selectedExercises);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FillSetDetailsScreen(
                selectedExercises: widget.selectedExercises,
              ),
            ),
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}

class FillSetDetailsScreen extends StatelessWidget {
  final List<dynamic> selectedExercises;

  FillSetDetailsScreen({required this.selectedExercises});

  final TextEditingController setNameController = TextEditingController();
  final TextEditingController setDescriptionController =
      TextEditingController();

  Future<void> _saveSetOnServer(BuildContext context) async {
    final String setName = setNameController.text;
    final String setDescription = setDescriptionController.text;
    final List<String> setCategoryIds = [];
    final List<String> setExercisesIds = [];

    selectedExercises.forEach((exercise) {
      final String exerciseId = exercise['_id'];
      final String categoryId = exercise['muscleCategory'];

      if (!setExercisesIds.contains(exerciseId)) {
        setExercisesIds.add(exerciseId);
      }

      if (!setCategoryIds.contains(categoryId)) {
        setCategoryIds.add(categoryId);
      }
    });

    if (setName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a set name')),
      );
      return;
    }

    try {
      String? token = await TokenManager.getToken();
      final body = json.encode({
        'name': setName,
        'description': setDescription,
        'categoryIds': setCategoryIds,
        'exerciseIds': setExercisesIds,
      });
      final response = await http.post(
        Uri.parse('http://192.168.0.105:4000/api/trainer/set'),
        headers: {'Content-Type': 'application/json', 'authorization': token!},
        body: body,
      );
      var responseBody = json.decode(response.body);
      if (responseBody['success']) {
        // If the set is successfully saved on the server
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GalleryScreen()),
        ); // Navigate back to the previous screen
      } else {
        // If there was an error saving the set
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save set')),
        );
      }
    } catch (error) {
      // If there was an error with the HTTP request
      print('Error saving set: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save set')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.fillSetDetailsScreenTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.selectExercises,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: selectedExercises.length,
                itemBuilder: (context, index) {
                  final exercise = selectedExercises[index];
                  return ListTile(
                    title: Text(exercise['name']),
                    // Display other exercise information as needed
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: setNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.setName,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: setDescriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.setDescription,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveSetOnServer(context); // Call the function to save set on server
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
