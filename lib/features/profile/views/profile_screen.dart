import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../token_manager.dart';
import 'package:expandable_text/expandable_text.dart';
import './edit_profile_screen.dart'; // Импортируем экран редактирования профиля

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = _fetchProfileData();
  }

  Future<Map<String, dynamic>> _fetchProfileData() async {
    String? token = await TokenManager.getToken();
    if (token == null) {
      // Если токен не существует, возвращаем пустой Map
      return {};
    }
    String? role = await TokenManager.getRole();
    var url = Uri.parse('http://192.168.0.106:4000/api/$role/get');
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
            'Date of Birth: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${birthDate.day}.${birthDate.month}.${birthDate.year} (Age: $age)',
          ),
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
            child: Text('Вход'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signin');
            },
            child: Text('Зарегистрироваться'),
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
            CircleAvatar(
              radius: 60,
              child: ClipOval(
                child: profileData["avatar"] != null
                    ? Image.network(
                  profileData["avatar"]["src"],
                  fit: BoxFit.cover, // Установите BoxFit.cover
                )
                    : Icon(Icons.person),
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
                    'About:',
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
                    'Achievements:',
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
                    'Specialization:',
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
                    'Students: ',
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
                'Weight: ${profileData["weight"]}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (profileData["height"] != null) ...[
              SizedBox(height: 8),
              Text(
                'Height: ${profileData["height"]}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (profileData["goal"] != null) ...[
              SizedBox(height: 8),
              Text(
                'Goal: ${profileData["goal"]}',
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
        title: const Text('Profile'),
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
                    title: Text('Выход'),
                    content: Text('Вы уверены, что хотите выйти?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Отмена выхода
                        },
                        child: Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Подтверждение выхода
                        },
                        child: Text('Выйти'),
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
