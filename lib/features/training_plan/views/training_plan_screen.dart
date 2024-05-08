import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:training_sync/features/exercises/views/exercise_screen.dart';
import 'package:training_sync/features/exercises/views/exercise_set_screen.dart';
import 'package:training_sync/token_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrainingPlanScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  TrainingPlanScreen({required this.studentId, required this.studentName});

  @override
  _TrainingPlanScreenState createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  late DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay = DateTime.now();
  TextEditingController _controller = TextEditingController();
  late List<DateTime> _trainingDates = [];
  List<dynamic> _selectedTrainings = [];
  List<dynamic> _selectedEvents = [];
  List<dynamic> _selectedEvent = [];
  List<dynamic> exercises = []; // Список упражнений
  List<dynamic> sets = []; // Список сетов
  bool isSelectingExercises =
      true; // Переменная для выбора между упражнениями и сетами

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
        _selectedDay = selectedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
        _selectedTrainings = _getTrainingsForDay(
            selectedDay); // Получаем выбранные тренировки для выбранной даты
        _showTrainingsModal(context);
      });
    }
  }

  List<Widget> _getEventsForDay(DateTime day) {
    if (_trainingDates.any((date) => date.isAtSameMomentAs(day))) {
      return [
        Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
        ),
      ];
    } else {
      return []; // Return an empty list
    }
  }

  void _fetchTrainings() async {
    String? token = await TokenManager.getToken();
    var url = Uri.parse('http://192.168.0.106:3000/api/student/training/get');
    var response = await http.post(
      url,
      headers: {'authorization': '$token', 'Content-Type': 'application/json'},
      body: json.encode({'studentId': widget.studentId}),
    );
    var responseBody = json.decode(response.body);
    if (responseBody['success']) {
      List<dynamic> trainings = responseBody['studentTrainings'];
      setState(() {
        _trainingDates = trainings.map((training) {
          var dateString = training['dates'][0]; // Получаем строку даты
          var dateParts = dateString.split('T')[0].split(
              '-'); // Разбиваем строку по символу 'T', затем по символу '-'
          return DateTime.utc(int.parse(dateParts[0]), int.parse(dateParts[1]),
              int.parse(dateParts[2]));
        }).toList();
        _selectedEvent = trainings;
      });
    }
  }

  List<dynamic> _getTrainingsForDay(DateTime day) {
    List<dynamic> trainingsForDay = _selectedEvent.where((training) {
      var dateString = training['dates'][0]; // Получаем строку даты
      var dateParts = dateString
          .split('T')[0]
          .split('-'); // Разбиваем строку по символу 'T', затем по символу '-'
      var trainingDate = DateTime.utc(
          int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
      return isSameDay(trainingDate, day);
    }).toList();

    // Устанавливаем значение текста контроллера в соответствии с выбранной тренировкой
    if (trainingsForDay.isNotEmpty) {
      var training = trainingsForDay[0]; // Берем первую тренировку из списка
      var dateString = training['dates'][0]; // Получаем строку даты
      var dateParts = dateString
          .split('T')[0]
          .split('-'); // Разбиваем строку по символу 'T', затем по символу '-'
      var trainingDate = DateTime.utc(
          int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));

      // Проверяем, является ли дата тренировки равной выбранной дате
      if (isSameDay(trainingDate, day)) {
        print(training['description']);
        _controller.text = training['description'];
      } else {
        _controller.clear();
      }
    } else {
      _controller.clear(); // Если тренировок нет на выбранную дату, очищаем контроллер
    }

    return trainingsForDay;
  }

  void _addTraining() async {
    List<String> selectedExerciseIds = [];
    List<String> selectedSetIds = [];

    // Добавляем выбранные упражнения и сеты в соответствующие списки
    for (dynamic exercise in exercises) {
      if (exercise['selected']) {
        selectedExerciseIds.add(exercise['_id']);
      }
    }

    for (dynamic set in sets) {
      if (set['selected']) {
        selectedSetIds.add(set['_id']);
      }
    }

    // Определяем URL в зависимости от наличия тренировок для выбранной даты
    String url = 'http://192.168.0.106:3000/api/student/training/add';
    if (_selectedTrainings.isNotEmpty && _selectedTrainings.any((training) => training['dates'] != null && training['dates'].isNotEmpty && isSameDay(DateTime.parse(training['dates'][0]), _selectedDay))) {
      // Если есть тренировки для выбранной даты, используем URL для обновления
      url = 'http://192.168.0.106:3000/api/student/training/update/${_selectedTrainings[0]['_id']}';
    }

    // Отправляем данные на сервер
    String? token = await TokenManager.getToken();
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'authorization': '$token',
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'studentId': widget.studentId,
        'dates': [_selectedDay.toIso8601String()],
        'description': _controller.text,
        'exerciseIds': selectedExerciseIds,
        'exerciseSetIds': selectedSetIds,
      }),
    );
    var responseBody = json.decode(response.body);
  }


  @override
  void initState() {
    super.initState();
    _fetchTrainings();
    _fetchExercises();
    _fetchSets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context)!.training_plan} ${widget.studentName}',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                onDaySelected: _onDaySelected,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getEventsForDay, // Pass the function directly
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              _selectedDay != null
                  ? 'Selected date: ${_selectedDay.day}.${_selectedDay.month}.${_selectedDay.year}'
                  : 'Select a date',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _openModal(context);
              },
              child: Text(AppLocalizations.of(context)!.addTraining),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainingsModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true, // Растягивает модальное окно на всю доступную высоту экрана
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Описание тренировки
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      _selectedTrainings.isNotEmpty
                          ? _selectedTrainings[0]['description']
                          : '', // Описание тренировки из базы данных
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    height: 200,
                    // Set a fixed height for the first ListView.builder
                    child: ListView.builder(
                      itemCount: _selectedTrainings.length,
                      itemBuilder: (context, index) {
                        final training = _selectedTrainings[index];
                        return Column(
                          children:
                          training['exercises'].map<Widget>((exercise) {
                            final exerciseName = exercise['name'];
                            final exerciseDescription = exercise['description'];
                            final exerciseId = exercise['_id'];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ExerciseScreen(
                                        exerciseId: exerciseId,
                                      )),
                                );
                              },
                              child: ListTile(
                                title: Text(
                                  exerciseName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  exerciseDescription,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 200,
                    // Set a fixed height for the first ListView.builder
                    child: ListView.builder(
                      itemCount: _selectedTrainings.length,
                      itemBuilder: (context, index) {
                        final training = _selectedTrainings[index];
                        return Column(
                          children: training['exerciseSets']
                              .map<Widget>((exerciseSet) {
                            final setName = exerciseSet['name'];
                            final setDescription = exerciseSet['description'];
                            final setId = exerciseSet['_id'];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ExerciseSetScreen(
                                        setId: setId,
                                      )),
                                );
                              },
                              child: ListTile(
                                title: Text(
                                  setName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  setDescription,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _openModal(context);
                    },
                    child: Text(AppLocalizations.of(context)!.editTraining),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Разрешаем прокрутку модального окна при появлении клавиатуры
      builder: (BuildContext bc) {
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Устанавливаем значения selected для упражнений и сетов перед открытием модального окна
              _selectedTrainings.forEach((training) {
                if (isSameDay(DateTime.parse(training['dates'][0]), _selectedDay)) {
                  training['exercises'].forEach((exercise) {
                    String exerciseId = exercise['_id'];
                    // Ищем упражнение по ID и устанавливаем для него галочку
                    exercises.forEach((e) {
                      if (e['_id'] == exerciseId) {
                        e['selected'] = true;
                      }
                    });
                  });

                  training['exerciseSets'].forEach((set) {
                    String setId = set['_id'];
                    // Ищем сет по ID и устанавливаем для него галочку
                    sets.forEach((s) {
                      if (s['_id'] == setId) {
                        s['selected'] = true;
                      }
                    });
                  });
                }
              });

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.addDescription,
                      border: OutlineInputBorder(),
                    )
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.selectedExercise),
                    onTap: () async {
                      isSelectingExercises = true;
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return SingleChildScrollView(
                                child: Container(
                                  height: 400,
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: exercises.length,
                                          itemBuilder: (context, index) {
                                            final exercise = exercises[index];
                                            // Проверяем, выбрано ли упражнение
                                            bool isSelected = exercise['selected'] ?? false;
                                            return CheckboxListTile(
                                              title: Text(
                                                exercise['name'],
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                exercise['description'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              value: isSelected,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  exercise['selected'] = value;
                                                  isSelected = value ?? false;
                                                  // Если упражнение выбрано, добавляем его в _selectedTrainings
                                                  if (isSelected) {
                                                    _selectedTrainings.add(exercise);
                                                  } else {
                                                    // Иначе удаляем его из _selectedTrainings
                                                    _selectedTrainings.removeWhere((ex) => ex['_id'] == exercise['_id']);
                                                  }
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.selectedSet),
                    onTap: () async {
                      isSelectingExercises = false;
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return SingleChildScrollView(
                                child: Container(
                                  height: 400,
                                  child: ListView.builder(
                                    itemCount: sets.length,
                                    itemBuilder: (context, index) {
                                      final set = sets[index];
                                      return CheckboxListTile(
                                        title: Text(
                                          set['name'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          set['description'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        value: set['selected'],
                                        onChanged: (bool? value) {
                                          setState(() {
                                            set['selected'] = value;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addTraining();
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.addTraining),
                  ),
                ],
              );
            },
          ),
        );
      },
    ).then((_) {
      // После закрытия модального окна сбрасываем значения selected для всех упражнений и сетов
      exercises.forEach((exercise) {
        exercise['selected'] = false;
      });

      sets.forEach((set) {
        set['selected'] = false;
      });
    });
  }


  Future<void> _fetchExercises() async {
    String? token = await TokenManager.getToken();
    final Uri url = Uri.parse(
        'http://192.168.0.106:3000/api/trainer/exercises?categoryId=');
    final response = await http.get(
      url,
      headers: {'authorization': token!},
    );
    final responseBody = json.decode(response.body);
    if (responseBody['success']) {
      setState(() {
        exercises = (responseBody['exercises'] ?? []).map((exercise) {
          // Добавляем дополнительное поле 'selected' для отслеживания выбора
          exercise['selected'] = false;
          return exercise;
        }).toList();
      });
    } else {
      print('Failed to fetch exercises: ${responseBody['message']}');
      // Handle the error scenario here
    }
  }

  Future<void> _fetchSets() async {
    String? token = await TokenManager.getToken();
    final Uri url = Uri.parse('http://192.168.0.106:3000/api/trainer/set');
    final response = await http.get(
      url,
      headers: {'authorization': token!},
    );
    final responseBody = json.decode(response.body);
    if (responseBody['success']) {
      setState(() {
        sets = (responseBody['exerciseSets'] ?? []).map((set) {
          // Добавляем дополнительное поле 'selected' для отслеживания выбора
          set['selected'] = false;
          return set;
        }).toList();
      });
    }
  }
}
