import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../token_manager.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SigninScreen extends StatefulWidget {
  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  String _userType = "student"; // Исходный тип пользователя
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _gymController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _specializationController =
  TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _confirmationCodeController =
  TextEditingController();

  // Переменная для отображения состояния подтверждения email
  bool _emailConfirmationRequired = false;

  String _selectedGender = '';

  // Файл изображения аватара
  // File? _avatarFile;

  // final _imagePicker = ImagePicker(); // Экземпляр выбора изображения

  // Future<void> _pickImage() async {
  //   final pickedFile =
  //       await _imagePicker.pickImage(source: ImageSource.gallery);
  //
  //   if (pickedFile != null) {
  //     setState(() {
  //       _avatarFile = File(pickedFile.path);
  //     });
  //   }
  // }

  Future<void> sendDataToServer() async {
    // URL вашего сервера, куда будет отправлен запрос
    var url = Uri.parse('http://192.168.0.105:3000/api/${_userType}/register');

    // Данные, которые вы хотите отправить на сервер
    var data = {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'country': _countryController.text,
      'city': _cityController.text,
      'district': _districtController.text,
      'birthDate': _birthDateController.text,
      'gender': _selectedGender,
    };
    if (_userType != "trainer") {
      data['weight'] = _weightController.text;
      data['height'] = _heightController.text;
      data['goal'] = _goalController.text;
    } else {
      data['about'] = _aboutController.text;
      data['achievements'] = _achievementsController.text;
      data['gym'] = _gymController.text;
      data['specialization'] = _specializationController.text;
    }

    // Отправляем POST-запрос на сервер с данными в формате JSON
    var response = await http.post(
      url,
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    // Декодируем тело ответа в объект Dart
    var responseBody = json.decode(response.body);
    print(responseBody['success']);

    // Проверяем поле 'success' в теле ответа
    if (responseBody['success']) {
      // Если данные успешно отправлены на сервер
      print(_emailConfirmationRequired);
      setState(() {
        _emailConfirmationRequired = true;
      });
      print(_emailConfirmationRequired);
      // Если подтверждение email не требуется, сохраняем токен
      TokenManager.saveToken(responseBody['token']);
      TokenManager.saveRole(_userType);
      print(responseBody['token']);
    } else {
      // Если произошла ошибка при отправке данных на сервер
      print('Ошибка отправки данных: ${responseBody['message']}');
    }
  }

  Future<void> confirmEmail(BuildContext context) async {
    // Отправляем запрос на сервер для подтверждения email
    // Используя код подтверждения, введенный пользователем
    var url = Uri.parse('http://192.168.0.105:3000/api/${_userType}/verify-email');
    var data = {
      'email': _emailController.text,
      'code': _confirmationCodeController.text,
    };
    var response = await http.post(
      url,
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    var responseBody = json.decode(response.body);
    if (responseBody['success']) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      // Если произошла ошибка при подтверждении email
      print('Ошибка подтверждения email: ${responseBody['message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.signIn), // Изменен заголовок на "Войти"
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: _emailConfirmationRequired
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _confirmationCodeController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.confirmationCode),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                confirmEmail(context);
              },
              child: Text(AppLocalizations.of(context)!.confirmEmail),
            ),
          ],
        )
            : Form(
          key: _formKey,
          child: Column(
            children: [
              // Группа радиокнопок для выбора типа пользователя
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _userType = "trainer";
                      });
                    },
                    child: Row(
                      children: [
                        Radio(
                          value: "trainer",
                          groupValue: _userType,
                          onChanged: (value) =>
                              setState(() => _userType = value as String),
                        ),
                        Text(AppLocalizations.of(context)!.trainer),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _userType = "student";
                      });
                    },
                    child: Row(
                      children: [
                        Radio(
                          value: "student",
                          groupValue: _userType,
                          onChanged: (value) =>
                              setState(() => _userType = value as String),
                        ),
                        Text(AppLocalizations.of(context)!.student),
                      ],
                    ),
                  ),
                ],
              ),

              // Общие поля регистрации (полное имя, email, пароль и т. д.)
              Column(children: [
                DropdownButton<String>(
                  value: _selectedGender,
                  items: [
                    DropdownMenuItem<String>(
                        child: Text(AppLocalizations.of(context)!.selectGender), value: ''),
                    DropdownMenuItem<String>(
                        child: Text(AppLocalizations.of(context)!.male), value: 'Male'),
                    DropdownMenuItem<String>(
                        child: Text(AppLocalizations.of(context)!.female), value: 'Female'),
                    DropdownMenuItem<String>(
                        child: Text(AppLocalizations.of(context)!.other), value: 'Other'),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                  hint: Text(AppLocalizations.of(context)!.selectGender),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  // Отступы по 10 пикселей сверху и снизу
                  child: TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fullName),
                    keyboardType: TextInputType.text,
                    validator: (value) => value!.isEmpty
                        ? 'Пожалуйста, введите ваше полное имя'
                        : null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  // Отступы по 10 пикселей сверху и снизу
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                    value!.isEmpty ? 'Пожалуйста, введите ваш email' : null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  // Отступы по 10 пикселей сверху и снизу
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: (value) => value!.isEmpty
                        ? 'Пожалуйста, введите ваш пароль'
                        : null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  // Отступы по 10 пикселей сверху и снизу
                  child: TextFormField(
                    controller: _countryController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.country),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  // Отступы по 10 пикселей сверху и снизу
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.city),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  // Отступы по 10 пикселей сверху и снизу
                  child: TextFormField(
                    controller: _districtController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.district),
                    keyboardType: TextInputType.text,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    picker.DatePicker.showDatePicker(
                      context,
                      showTitleActions: true,
                      onChanged: (date) {},
                      onConfirm: (date) {
                        setState(() {
                          _birthDateController.text = DateFormat('yyyy-MM-dd').format(date);
                        });
                      },
                      currentTime: DateTime.now(),
                    );
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _birthDateController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dateOfBirth),
                    ),
                  ),
                ),
              ]),
              if (_userType != "trainer")
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      // Отступы по 10 пикселей сверху и снизу
                      child: TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.weight),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty
                            ? 'Пожалуйста, введите ваш вес (килограммы)'
                            : null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      // Отступы по 10 пикселей сверху и снизу
                      child: TextFormField(
                        controller: _heightController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.height),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty
                            ? 'Пожалуйста, введите ваш рост (сантиметры)'
                            : null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      // Отступы по 10 пикселей сверху и снизу
                      child: TextFormField(
                        controller: _goalController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.goal),
                        keyboardType: TextInputType.text,
                        maxLines: 5,
                        validator: (value) => value!.isEmpty
                            ? 'Пожалуйста, введите вашу цель'
                            : null,
                      ),
                    ),
                  ],
                ),
              // Условное отображение дополнительных полей на основе типа пользователя
              if (_userType == "trainer")
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      // Отступы по 10 пикселей сверху и снизу
                      child: TextFormField(
                        controller: _aboutController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profileAbout),
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      // Отступы по 10 пикселей сверху и снизу
                      child: TextFormField(
                        controller: _achievementsController,
                        decoration:
                        InputDecoration(labelText: AppLocalizations.of(context)!.achiv),
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      // Отступы по 10 пикселей сверху и снизу
                      child: TextFormField(
                        controller: _gymController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.gym),
                        keyboardType: TextInputType.text,
                        maxLines: 5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      // Отступы по 10 пикселей сверху и снизу
                      child: TextFormField(
                        controller: _specializationController,
                        decoration:
                        InputDecoration(labelText: AppLocalizations.of(context)!.specialization),
                        keyboardType: TextInputType.text,
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              Text(
                AppLocalizations.of(context)!.enterPolicyAndTerms,
                textAlign: TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  launch('http://training-sync.com/policy');
                },
                child: Text(
                  AppLocalizations.of(context)!.privacy_policy,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' & ',
                textAlign: TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  launch('http://training-sync.com/terms');
                },
                child: Text(
                  AppLocalizations.of(context)!.terms_of_service,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              // Кнопка отправки и логика валидации (перемещена за пределы блока условия)
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    sendDataToServer();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 0),
                  // Применение стиля для голубой кнопки
                  // Цвет текста кнопки
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14.0), // Радиус кнопки
                  ),
                  padding: EdgeInsets.symmetric(vertical: 17.0),
                  // Отступы сверху и снизу
                  textStyle: TextStyle(
                    fontSize: 14.0, // Размер текста
                    fontWeight: FontWeight.w600, // Жирность текста
                  ),
                ),
                child:
                Text(AppLocalizations.of(context)!.signIn), // Изменен текст кнопки на "Войти"
              ),
            ],
          ),
        ),
      ),
    );
  }
}

