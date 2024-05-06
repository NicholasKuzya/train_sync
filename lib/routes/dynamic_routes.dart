import 'package:training_sync/features/chat/views/chat_screen.dart';
import 'package:training_sync/features/exercises/views/exercise_screen.dart';
import 'package:training_sync/features/exercises/views/exercise_set_screen.dart';
import 'package:training_sync/features/training_plan/views/training_plan_screen.dart';
import 'package:training_sync/features/video_editor/views/video_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:training_sync/features/any_profile/views/any_profile_screen.dart';
import 'package:training_sync/features/workouts/views/workout_screen.dart';

class DynamicRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name!.startsWith('/profile/')) {
      // Обработка динамического маршрута для профиля
      // Извлекаем идентификатор из пути
      final id = settings.name!.split('/').last;
      return MaterialPageRoute(
        builder: (context) => AnyProfileScreen(profileId: id),
      );
    }
    if (settings.name!.startsWith('/chat/')) {
      // Обработка динамического маршрута для чата
      // Извлекаем идентификатор чата и студента из пути
      final parts = settings.name!.split('/');
      final chatId = parts[2];
      final companionId = parts[3];
      return MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: chatId, companionId: companionId),
      );
    }
    if (settings.name!.startsWith('/gallery/')) {
      // Обработка динамического маршрута для чата
      // Извлекаем идентификатор чата и студента из пути
      final parts = settings.name!.split('/');
      final videoPath = parts[2];
      return MaterialPageRoute(
        builder: (context) => VideoEditorScreen(videoPath: videoPath),
      );
    }
    if (settings.name!.startsWith('/exercise/')) {
      // Обработка динамического маршрута для чата
      // Извлекаем идентификатор чата и студента из пути
      final parts = settings.name!.split('/');
      final exerciseId = parts[2];
      return MaterialPageRoute(
        builder: (context) => ExerciseScreen(exerciseId: exerciseId),
      );
    }
    if (settings.name!.startsWith('/set/')) {
      // Обработка динамического маршрута для чата
      // Извлекаем идентификатор чата и студента из пути
      final parts = settings.name!.split('/');
      final setId = parts[2];
      return MaterialPageRoute(
        builder: (context) => ExerciseSetScreen(setId: setId),
      );
    }
    if (settings.name!.startsWith('/setting/')) {
      // Обработка динамического маршрута для чата
      // Извлекаем идентификатор чата и студента из пути
      final parts = settings.name!.split('/');
      final studentId = parts[2];
      final studentName = parts[3];
      return MaterialPageRoute(
        builder: (context) => TrainingPlanScreen(studentId: studentId, studentName: studentName),
      );
    }
    if (settings.name!.startsWith('/workout/')) {
      // Обработка динамического маршрута для чата
      // Извлекаем идентификатор чата и студента из пути
      final parts = settings.name!.split('/');
      final trainingId = parts[2];
      return MaterialPageRoute(
        builder: (context) => WorkoutAboutScreen(trainingId: trainingId),
      );
    }
    // Если маршрут не совпадает с динамическими маршрутами, вы можете вернуть
    // пустой экран или другой экран по умолчанию.
    return MaterialPageRoute(builder: (context) => Placeholder());
  }
}
