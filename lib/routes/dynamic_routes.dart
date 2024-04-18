import 'package:app2/features/chat/views/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:app2/features/any_profile/views/any_profile_screen.dart';

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
      final studentId = parts[3];
      return MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: chatId, studentId: studentId),
      );
    }
    // Если маршрут не совпадает с динамическими маршрутами, вы можете вернуть
    // пустой экран или другой экран по умолчанию.
    return MaterialPageRoute(builder: (context) => Placeholder());
  }
}
