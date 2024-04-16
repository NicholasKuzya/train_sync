import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../token_manager.dart'; // Импортируем ваш файл token_manager.dart

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _userType = "student"; // По умолчанию тип пользователя - ученик

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();

  bool _showResetPassword = false;
  bool _showCodeFiled = false;
  bool _showResetBtn = false;

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // URL для отправки запроса на сервер в зависимости от типа пользователя
    String url = 'http://192.168.0.106:4000/api/$_userType/login';

    // Данные для отправки на сервер
    var data = {'email': email, 'password': password};

    // Отправка POST-запроса на сервер
    var response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    // Обработка ответа сервера
    var responseData = json.decode(response.body);
    if (responseData['success']) {
      // Если вход успешен, сохраняем токен и роль пользователя
      String token = responseData['token'];
      TokenManager.saveToken(token);
      TokenManager.saveRole(_userType);
      print(token);
      // Перенаправляем пользователя на страницу профиля
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      // Если вход неуспешен, можно обработать ошибку
      print('Login failed: ${responseData['message']}');
    }
  }

  Future<void> _sendResetCode() async {
    String email = _emailController.text;

    // URL для отправки запроса на сервер для отправки кода на почту
    String url = 'http://192.168.0.106:4000/api/$_userType/reset/code';

    // Данные для отправки на сервер
    var data = {'email': email};

    // Отправка POST-запроса на сервер
    var response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    // Обработка ответа сервера
    var responseData = json.decode(response.body);
    if (responseData['success']) {
      // Если код успешно отправлен, можно обработать ответ
      print('Reset code sent successfully');
      setState(() {
        _showCodeFiled = true;
        _showResetPassword = true;
        _showResetBtn = true;
      });
    } else {
      // Если отправка кода неуспешна, можно обработать ошибку
      print('Failed to send reset code: ${responseData['message']}');
    }
  }

  Future<void> _resetPassword() async {
    String email = _emailController.text;
    String code = _codeController.text;
    String newPassword = _newPasswordController.text;

    // URL для отправки запроса на сервер для сброса пароля
    String url = 'http://192.168.0.106:4000/api/$_userType/reset/pass';

    // Данные для отправки на сервер
    var data = {'email': email, 'code': code, 'newPassword': newPassword};

    // Отправка POST-запроса на сервер
    var response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    // Обработка ответа сервера
    var responseData = json.decode(response.body);
    if (responseData['success']) {
      // Если сброс пароля прошел успешно, можно обработать ответ
      print('Password reset successfully');
    } else {
      // Если сброс пароля неуспешен, можно обработать ошибку
      print('Failed to reset password: ${responseData['message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Выпадающий список для выбора типа пользователя
            DropdownButton<String>(
              value: _userType,
              onChanged: (String? newValue) {
                setState(() {
                  _userType = newValue!;
                });
              },
              items: <String>['student', 'trainer']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            // Поле для ввода email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            // Условное отображение полей для сброса пароля
            if (!_showResetPassword) ...[
              // Поле для ввода пароля
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              // Кнопка для отправки данных на сервер
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showResetPassword = true;
                  });
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ] else if (_showCodeFiled) ...[
              // Поле для ввода кода сброса пароля

              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Verification Code'),
              ),
              SizedBox(height: 16.0),
              // Поле для ввода нового пароля
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              // Кнопка для отправки запроса на получение кода
              SizedBox(height: 16.0),
              // Кнопка для сброса пароля
              ElevatedButton(
                onPressed: _resetPassword,
                child: Text('Reset Password'),
              ),
            ] else if (_showResetPassword && !_showCodeFiled) ...[
              ElevatedButton(
                onPressed: () {
                  _sendResetCode();
                },
                child: Text('Get Code'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
