import 'package:flutter/material.dart';
import 'package:app2/theme/dark_theme/dark_theme.dart';
import 'package:app2/routes/dynamic_routes.dart';
import 'package:app2/routes/routes.dart'; // Подключаем файл с обычными маршрутами

class TrainSync extends StatelessWidget {
  const TrainSync({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Train Sync',
        theme: darkTheme,
        onGenerateRoute: DynamicRoutes.generateRoute, // Используем метод из dynamic_routes.dart
        routes: routes
    );
  }
}
