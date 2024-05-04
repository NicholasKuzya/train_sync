import 'package:flutter/material.dart';
import 'package:training_sync/theme/dark_theme/dark_theme.dart';
import 'package:training_sync/routes/dynamic_routes.dart';
import 'package:training_sync/routes/routes.dart'; // Подключаем файл с обычными маршрутами
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrainSync extends StatelessWidget {
  const TrainSync({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Train Sync',
        localizationsDelegates: [
          AppLocalizations.delegate, // Делегат для загрузки локализаций
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''), // Поддерживаемые языки: английский и русский
          const Locale('ru', ''),
        ],
        theme: darkTheme,
        onGenerateRoute: DynamicRoutes.generateRoute, // Используем метод из dynamic_routes.dart
        routes: routes
    );
  }
}
