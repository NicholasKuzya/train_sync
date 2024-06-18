import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:training_sync/features/workouts/views/workout_screen.dart';
import '../../../token_manager.dart';
import 'package:training_sync/admob_service.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay = DateTime.now();
  List<DateTime> _trainingDates = [];
  List<dynamic> _selectedTrainings = [];

  void _fetchTrainings() async {
    String? token = await TokenManager.getToken();
    var url = Uri.parse('https://training-sync.com/api/student/get/training');
    var response = await http.get(
      url,
      headers: {'authorization': '$token'},
    );
    var responseBody = json.decode(response.body);
    print(responseBody);
    if (responseBody['success']) {
      setState(() {
        _trainingDates = (responseBody['student']['trainingPlans'] as List)
            .map((training) => DateTime.parse(training['dates'][0]))
            .toList();
        _selectedTrainings = responseBody['student']['trainingPlans'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTrainings();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
        _selectedDay = selectedDay;
      });
      _showTrainingModal(selectedDay);
    }
  }

  void _showTrainingModal(DateTime selectedDay) {
    List<dynamic> trainingsForDay = _selectedTrainings
        .where((training) =>
        DateTime.parse(training['dates'][0]).isAtSameMomentAs(selectedDay))
        .toList();

    if (trainingsForDay.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                for (var training in trainingsForDay)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WorkoutAboutScreen(trainingId: training['_id'])),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        training['description'],
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myTraining),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              eventLoader: (day) =>
              _trainingDates.contains(day) ? ['event'] : [],
            ),
            AdBanner()
          ],
        ),
      ),
    );
  }
}
