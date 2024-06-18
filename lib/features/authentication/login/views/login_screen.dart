import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../token_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _userType = "student";

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();

  bool _showResetPassword = false;
  bool _showCodeFiled = false;
  bool _showResetBtn = false;
  bool _loading = false;

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    String url = 'https://training-sync.com/api/$_userType/login';

    var data = {'email': email, 'password': password};

    var response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    var responseData = json.decode(response.body);
    if (responseData['success']) {
      String token = responseData['token'];
      TokenManager.saveToken(token);
      TokenManager.saveRole(_userType);
      print(token);
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      print('Login failed: ${responseData['message']}');
    }
  }

  Future<void> _sendResetCode() async {
    String email = _emailController.text;

    String url = 'https://training-sync.com/api/$_userType/reset/code';

    var data = {'email': email};

    setState(() {
      _loading = true;
    });

    var response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    var responseData = json.decode(response.body);
    if (responseData['success']) {
      setState(() {
        _showCodeFiled = true;
        _showResetPassword = true;
        _showResetBtn = true;
        _loading = false;
      });
    } else {
      print('Failed to send reset code: ${responseData['message']}');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    String email = _emailController.text;
    String code = _codeController.text;
    String newPassword = _newPasswordController.text;

    String url = 'https://training-sync.com/api/$_userType/reset/pass';

    var data = {'email': email, 'code': code, 'newPassword': newPassword};

    setState(() {
      _loading = true;
    });

    var response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    var responseData = json.decode(response.body);
    if (responseData['success']) {
      _showSuccessDialog(AppLocalizations.of(context)!.resetPasswordSuccess);
      setState(() {
        _loading = false;
      });
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showErrorDialog(AppLocalizations.of(context)!.resetPasswordFailed);
      setState(() {
        _loading = false;
      });
    }
  }
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.logIn),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.0),
                if (!_showResetPassword) ...[
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text(AppLocalizations.of(context)!.logIn),
                  ),
                  SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showResetPassword = true;
                      });
                    },
                    child: Text(
                      AppLocalizations.of(context)!.forgotPassword,
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ] else if (_showCodeFiled) ...[
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.confirmationCode),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.newPassword),
                    obscureText: true,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _resetPassword,
                    child: Text(AppLocalizations.of(context)!.resetPassword),
                  ),
                ] else if (_showResetPassword && !_showCodeFiled) ...[
                  ElevatedButton(
                    onPressed: () {
                      _sendResetCode();
                    },
                    child: Text(AppLocalizations.of(context)!.getCode),
                  ),
                ]
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
