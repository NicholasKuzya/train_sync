import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TrainingPlanScreen extends StatefulWidget {
  const TrainingPlanScreen({Key? key}) : super(key: key);

  @override
  _TrainingPlanScreenState createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  DateTime selectedDate = DateTime.now(); // Выбранная дата по умолчанию

  // Функция для отображения контекстного меню при выборе дня
  void _showPopupMenu(BuildContext context, DateTime selectedDate) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
          Rect.fromPoints(Offset.zero, overlay.localToGlobal(overlay.size.bottomRight(Offset.zero))),
          Offset.zero & overlay.size),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: ListTile(
            title: Text('Настроить план тренировок на $selectedDate'),
            onTap: () {
              // Здесь можно добавить логику для настройки плана тренировок на выбранный день
              Navigator.pop(context); // закрываем контекстное меню после выбора
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройка плана тренировок'),
      ),
      body: Column(
          children: [
            Text('Hello'),
    ]
    ),
    );
  }
}
