import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../../token_manager.dart';
import 'package:expandable_text/expandable_text.dart';
import './edit_profile_screen.dart'; // Импортируем экран редактирования профиля
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileData;
  late String _avatarUrl;
  Future<void> _pickAvatar() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery); // Открываем галерею
    if (image != null) {
      // Если пользователь выбрал изображение
      setState(() {
        _avatarUrl = image.path; // Обновляем URL аватарки
      });

      // Отправляем изображение на сервер
      await _uploadAvatar(image);
    }
  }
  // Метод для отправки изображения на сервер
  Future<void> _uploadAvatar(XFile imageFile) async {
    final url = Uri.parse('http://192.168.0.106:3000/api/media/avatar');
    String? token = await TokenManager.getToken();
    if(token != null) {
      final request = http.MultipartRequest('POST', url);

      // Добавляем заголовок авторизации
      request.headers['authorization'] = token!;

      // Добавляем файл изображения к запросу
      request.files.add(
          await http.MultipartFile.fromPath('avatar', imageFile.path));

      // Отправляем запрос и получаем ответ
      final response = await request.send();

      final jsonResponse = await response.stream.bytesToString();
      final decodedResponse = json.decode(jsonResponse);

      // Проверяем наличие ключа 'success' в JSON-ответе
      if (decodedResponse['success'] != null && decodedResponse['success']) {
        // Если ключ 'success' есть и равен true, выводим сообщение
        print('Uploaded new image: ${decodedResponse['message']}');
      } else {
        // Если ключ 'success' отсутствует или равен false, выводим сообщение об ошибке
        print('Failed to upload avatar: ${decodedResponse['message']}');
      }
    } else {
      // Обработка ситуации, когда токен отсутствует
      print('Token is null, unable to upload avatar');
    }
  }
  @override
  void initState() {
    super.initState();
    _profileData = _fetchProfileData();
    _profileData.then((profileData) {
      setState(() {
        _avatarUrl = profileData['avatar'] != null ? profileData['avatar']['src'] : '';
      });
    });
  }
    Future<Map<String, dynamic>> _fetchProfileData() async {
      String? token = await TokenManager.getToken();
      if (token == null) {
        // Если токен не существует, возвращаем пустой Map
        return {};
      }
      String? role = await TokenManager.getRole();
      var url = Uri.parse('http://192.168.0.106:3000/api/$role/get');
      var response = await http.post(
        url,
        headers: {'authorization': '$token'},
      );
      var data = json.decode(response.body);
      return data['$role'];
    }
  Widget _buildBirthDate(Map<String, dynamic> profileData) {
    if (profileData.containsKey("birthDate")) {
      DateTime birthDate = DateTime.parse(profileData["birthDate"]);
      int age = DateTime.now().year - birthDate.year;

      return Row(
        children: [
          Text(
            '${AppLocalizations.of(context)!.dateOfBirth}: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${birthDate.day}.${birthDate.month}.${birthDate.year}',
          ),
          SizedBox(height: 10),
          Text(' ($age)', style: TextStyle(fontWeight: FontWeight.bold),)
        ],
      );
    } else {
      return Container(); // Возвращаем пустой контейнер, если дата рождения отсутствует
    }
  }

  Widget _buildProfileWidget(Map<String, dynamic> profileData) {
    if (profileData.isEmpty) {
      // Если профиль пустой (пользователь не авторизован), отображаем ссылки на вход и регистрацию
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text(AppLocalizations.of(context)!.logIn),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signin');
            },
            child: Text(AppLocalizations.of(context)!.signIn),
          ),
        ],
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
// При нажатии на аватарку, открываем диалоговое окно
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.changeAvatar),
                      content: Text(AppLocalizations.of(context)!.changeAvatarText),
                      actions: <Widget>[
// Кнопка Отмена
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
// Кнопка Подтвердить
                        TextButton(
                          onPressed: () {
// При подтверждении, вызываем метод для выбора новой аватарки
                            _pickAvatar();
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.confirm),
                        ),
                      ],
                    );
                  },
                );
              },
              child: CircleAvatar(
                radius: 60,
                child: ClipOval(
                  child: profileData["avatar"] != null
                      ? Image.network(
                    'http://192.168.0.106:3000/api/uploads/avatar/${profileData["avatar"]["src"]}',
                    fit: BoxFit.cover, // Установите BoxFit.cover
                    width: 120, // Ширина изображения
                    height: 120, // Высота изображения
                  )
                      : Icon(Icons.person),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              profileData["fullName"],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${profileData["country"]}, ${profileData["city"]}${profileData["gym"] != null ? ', ' + profileData["gym"] : ''}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildBirthDate(profileData),
            SizedBox(height: 8),
            if (profileData["about"] != null && profileData["about"].isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.profileAbout,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ExpandableText(
                    profileData["about"],
                    maxLines: 3,
                    expandText: 'more',
                    collapseText: 'less',
                  ),
                ],
              ),
            ],
            SizedBox(height: 8.0),
            if (profileData["achievements"] != null &&
                profileData["achievements"].isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.achiv,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ExpandableText(
                    profileData["achievements"],
                    maxLines: 3,
                    expandText: 'more',
                    collapseText: 'less',
                  ),
                ],
              ),
            ],
            SizedBox(height: 8.0),
            if (profileData["specialization"] != null &&
                profileData["specialization"].isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.specialization,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ExpandableText(
                    profileData["specialization"],
                    maxLines: 3,
                    expandText: 'more',
                    collapseText: 'less',
                  ),
                ],
              ),
            ],
            SizedBox(height: 8),
            if (profileData["students"] != null) ...[
              Row(
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.students}: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${profileData["students"].isEmpty ? 0 : profileData["students"].length}',
                  ),
                ],
              ),
            ],
            // Добавляем поля для студентов
            if (profileData["weight"] != null) ...[
              SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context)!.weight}: ${profileData["weight"]}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (profileData["height"] != null) ...[
              SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context)!.height}: ${profileData["height"]}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (profileData["goal"] != null) ...[
              SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context)!.goal}: ${profileData["goal"]}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title_profile),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              bool confirmLogout = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.exit),
                    content: Text(AppLocalizations.of(context)!.exitQuestion),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Отмена выхода
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Подтверждение выхода
                        },
                        child: Text(AppLocalizations.of(context)!.exit),
                      ),
                    ],
                  );
                },
              );

              if (confirmLogout ?? false) {
                // Если подтвержден выход, удаляем токен и роль
                await TokenManager.deleteToken();
                await TokenManager.deleteRole();
                // Переход на домашнюю страницу
                Navigator.popUntil(context, ModalRoute.withName('/'));
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load profile data: ${snapshot.error}'),
            );
          } else {
            Map<String, dynamic> profileData = snapshot.data!;
            return _buildProfileWidget(profileData);
          }
        },
      ),
    );
  }
}
