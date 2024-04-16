import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../token_manager.dart';

class SigninScreen extends StatefulWidget {
  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  String _userType = "student"; // Initial user type
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

  // Объявите переменную для отображения состояния подтверждения email
  bool _emailConfirmationRequired = false;

  String _selectedGender = 'Male';

  // Avatar image file
  // File? _avatarFile;

  // final _imagePicker = ImagePicker(); // Image picker instance

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
    var url = Uri.parse('http://192.168.0.106:4000/api/${_userType}/register');

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
        print('Error sending data: ${responseBody['message']}');
      }
  }

  Future<void> confirmEmail(BuildContext context) async {
    // Отправляем запрос на сервер для подтверждения email
    // Используя код подтверждения, введенный пользователем
    var url = Uri.parse('http://192.168.0.106:4000/api/${_userType}/verify-email');
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
        print('Error confirming email: ${responseBody['message']}');
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'), // Changed title to "Sign In"
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: _emailConfirmationRequired
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _confirmationCodeController,
                    decoration: InputDecoration(labelText: 'Confirmation Code'),
                    keyboardType: TextInputType.number,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      confirmEmail(context);
                    },
                    child: Text('Confirm Email'),
                  ),
                ],
              )
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Radio group for user type selection
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
                              Text('Trainer'),
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
                              Text('Student'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Common registration fields (fullName, email, password, etc.)
                    Column(children: [
                      DropdownButton<String>(
                        value: _selectedGender,
                        items: [
                          DropdownMenuItem<String>(
                              child: Text('Male'), value: 'Male'),
                          DropdownMenuItem<String>(
                              child: Text('Female'), value: 'Female'),
                          DropdownMenuItem<String>(
                              child: Text('Other'), value: 'Other'),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        hint: Text('Select Gender'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        // Отступы по 10 пикселей сверху и снизу
                        child: TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(labelText: 'Full Name'),
                          keyboardType: TextInputType.text,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your full name'
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
                              value!.isEmpty ? 'Please enter your email' : null,
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
                              ? 'Please enter your password'
                              : null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        // Отступы по 10 пикселей сверху и снизу
                        child: TextFormField(
                          controller: _countryController,
                          decoration: InputDecoration(labelText: 'Country'),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        // Отступы по 10 пикселей сверху и снизу
                        child: TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(labelText: 'City'),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        // Отступы по 10 пикселей сверху и снизу
                        child: TextFormField(
                          controller: _districtController,
                          decoration: InputDecoration(labelText: 'District'),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          controller: _birthDateController,
                          decoration: InputDecoration(labelText: 'Birth Date'),
                          keyboardType: TextInputType.datetime,
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
                              decoration: InputDecoration(labelText: 'Weight'),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your weight (centimeters)'
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            // Отступы по 10 пикселей сверху и снизу
                            child: TextFormField(
                              controller: _heightController,
                              decoration: InputDecoration(labelText: 'Height'),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your height (kg)'
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            // Отступы по 10 пикселей сверху и снизу
                            child: TextFormField(
                              controller: _goalController,
                              decoration: InputDecoration(labelText: 'Goal'),
                              keyboardType: TextInputType.text,
                              maxLines: 5,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your goal'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    // Conditional rendering of additional fields based on user type
                    if (_userType == "trainer")
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            // Отступы по 10 пикселей сверху и снизу
                            child: TextFormField(
                              controller: _aboutController,
                              decoration: InputDecoration(labelText: 'About'),
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
                                  InputDecoration(labelText: 'Achievements'),
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            // Отступы по 10 пикселей сверху и снизу
                            child: TextFormField(
                              controller: _gymController,
                              decoration: InputDecoration(labelText: 'Gym'),
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
                                  InputDecoration(labelText: 'Specialization'),
                              keyboardType: TextInputType.text,
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),

                    // Submit button and validation logic (moved outside conditional block)
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
                          Text('Sign In'), // Changed button text to "Sign In"
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
