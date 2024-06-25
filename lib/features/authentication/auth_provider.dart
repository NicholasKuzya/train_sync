import 'package:flutter/material.dart';
import 'package:training_sync/token_manager.dart'; // Подставьте корректный импорт для вашего TokenManager

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _role = '';

  bool get isLoggedIn => _isLoggedIn;
  String get role => _role;

  AuthProvider() {
    // Проверяем наличие токена при инициализации
    checkToken();
  }

  Future<void> checkToken() async {
    String? token = await TokenManager.getToken();
    if (token != null && token.isNotEmpty && token != '') {
      // Если токен существует, считаем пользователя авторизованным
      _isLoggedIn = true;
      _role = await TokenManager.getRole() ?? '';
    } else {
      // Иначе пользователь не авторизован
      _isLoggedIn = false;
      _role = '';
    }
    notifyListeners();
  }

  void login(String role) {
    _isLoggedIn = true;
    _role = role;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _role = '';
    // Удаляем токен из хранилища при выходе
    TokenManager.deleteToken();
    TokenManager.deleteToken();
    notifyListeners();
  }
}
