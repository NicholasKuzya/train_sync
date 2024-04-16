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
    // Если маршрут не совпадает с динамическими маршрутами, вы можете вернуть
    // пустой экран или другой экран по умолчанию.
    return MaterialPageRoute(builder: (context) => Placeholder());
  }
}
