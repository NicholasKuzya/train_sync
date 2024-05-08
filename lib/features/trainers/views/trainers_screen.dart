import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../token_manager.dart';
import 'package:training_sync/features/chat/views/chat_screen.dart'; // Импорт ChatScreen
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Trainer {
  final String id; // Добавляем поле id
  final String fullName;
  final String avatarUrl;
  final String about;

  Trainer({required this.id, required this.fullName, required this.avatarUrl, required this.about});
}

class TrainerInputScreen extends StatefulWidget {
  @override
  _TrainerInputScreenState createState() => _TrainerInputScreenState();
}

class _TrainerInputScreenState extends State<TrainerInputScreen> {
  String _selectedCountry = '';
  String _selectedCity = '';
  String _selectedDistrict = '';
  String _selectedSortBy = '';
  String _searchQuery = '';
  TextEditingController _messageController = TextEditingController();
  String _serverResponse = '';

  List<Trainer> _trainers = [];
  List<String> _countries = [];
  List<String> _cities = [];
  List<String> _districts = [];


  @override
  void initState() {
    super.initState();
    _fetchTrainers();
  }

  Future<void> _fetchTrainers() async {
    String? token = await TokenManager.getToken();
    if (token == null) {
      // Handle case when token is not available
      return;
    }
    final response = await http.get(
      Uri.parse('http://192.168.0.106:3000/api/trainer/get/all?country=$_selectedCountry&city=$_selectedCity&district=$_selectedDistrict&sortBy=$_selectedSortBy&searchQuery=$_searchQuery'),
      headers: {
        'authorization': token,
        'Content-Type': 'application/json'
      },
    );
    final data = json.decode(response.body);
    if (data['success']) {
      final dataTrainers = data['trainers'] as List<dynamic>;

      setState(() {
        dataTrainers.forEach((trainer) {
          String country = trainer['country'];
          String city = trainer['city'];
          String district = trainer['district'];

          // Проверяем, что значение еще не добавлено в массив
          if (!_countries.contains(country)) {
            _countries.add(country);
          }
          if (!_cities.contains(city)) {
            _cities.add(city);
          }
          if (!_districts.contains(district)) {
            _districts.add(district);
          }
        });
        _trainers = dataTrainers.map((item) {
          final avatarUrl = item['avatar'] != null ? item['avatar']['src'] : '';
          return Trainer(
            id: item['_id'], // Устанавливаем id тренера
            fullName: item['fullName'],
            avatarUrl: avatarUrl,
            about: item['about'],
          );
        }).toList();
      });
    } else {
      // Handle error response from server
    }
  }

  void _navigateToTrainerProfile(String id) {
    Navigator.pushNamed(context, '/profile/$id');
  }

  Future<void> _sendTrainingRequest(String trainerId, String message) async {
    String? token = await TokenManager.getToken();
    if (token == null) {
      // Handle case when token is not available
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.106:3000/api/student/training/send-request'),
        headers: {
          'authorization': token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'trainerId': trainerId,
          'message': message,
        }),
      );

      final responseData = json.decode(response.body);
      if (responseData['success']) {
        setState(() {
          _serverResponse = responseData['message']; // Обновляем состояние с полученным сообщением
        });
      } else {
        setState(() {
          _serverResponse = responseData['message'];
        });
      }
    } catch (error) {
      setState(() {
        _serverResponse = 'Ошибка при отправке запроса: $error';
      });
    }
  }

  void _showMessageDialog(String trainerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.sendRequest),
          content: TextField(
            controller: _messageController,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.requests_message),
            maxLines: null, // Многострочное поле
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.send),
              onPressed: () {
                String message = _messageController.text;
                _sendTrainingRequest(trainerId, message);
                Navigator.of(context).pop();
              },
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
        title: Text(AppLocalizations.of(context)!.trainers),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // Обновляем поисковой запрос при изменении текста
                });
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.searchTrainers,
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _fetchTrainers(); // Выполняем поиск при нажатии на кнопку
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCountry.isNotEmpty ? _selectedCountry : null,
              items: _countries.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.isEmpty ? 'Not Selected' : value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountry = newValue ?? '';
                  _fetchTrainers(); // Обновляем список тренеров после выбора страны
                });
              },
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.country),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCity.isNotEmpty ? _selectedCity : null,
              items: _cities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.isEmpty ? 'Not Selected' : value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCity = newValue ?? '';
                  _fetchTrainers();
                });
              },
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.city),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedDistrict.isNotEmpty ? _selectedDistrict : null,
              items: _districts.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.isEmpty ? 'Not Selected' : value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDistrict = newValue ?? '';
                  _fetchTrainers();
                });
              },
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.district),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _trainers.length,
                itemBuilder: (context, index) {
                  final trainer = _trainers[index];
                  return GestureDetector(
                    onTap: () {
                      _navigateToTrainerProfile(trainer.id);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              child: ClipOval(
                                child: trainer.avatarUrl.isNotEmpty && trainer.avatarUrl != ""
                                    ? Image.network(
                                  'http://192.168.0.106:3000/api/uploads/avatar/${trainer.avatarUrl}',
                                  fit: BoxFit.cover,
                                  width: 60, // Ширина изображения
                                  height: 60,
                                )
                                    : Icon(Icons.person),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trainer.fullName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () {
                                _showMessageDialog(trainer.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.chat),
                              onPressed: () async {
                                try {
                                  String? token = await TokenManager.getToken();

                                  // Отправляем запрос на получение studentId
                                  var studentResponse = await http.post(
                                    Uri.parse('http://192.168.0.106:3000/api/student/get'),
                                    headers: {'authorization': '$token'},
                                  );
                                  var studentData = json.decode(studentResponse.body);
                                  if (!studentData['success']) {
                                    throw Exception('Failed to get student data');
                                  }
                                  print(studentData);
                                  String? studentId = studentData['student']['_id'];
                                  print(studentId);

                                  // Проверяем, что studentId не равно null
                                  if (studentId != null) {
                                    // Отправляем запрос на создание чата
                                    var createChatResponse = await http.post(
                                      Uri.parse('http://192.168.0.106:3000/api/chat/create'),
                                      headers: {'authorization': '$token', 'Content-Type': 'application/json'},
                                      body: json.encode({
                                        'studentId': studentId,
                                        'trainerId': trainer.id,
                                      }),
                                    );
                                    var createChatData = json.decode(createChatResponse.body);
                                    print(createChatData);
                                    if (createChatData['success']) {
                                      // Обработка успешного создания чата
                                      // Например, перенаправление на экран чата
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(chatId: createChatData['chat']['_id'], companionId: trainer.id),
                                        ),
                                      );
                                    } else {
                                      // Обработка ошибки создания чата
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(createChatData['message']),
                                        backgroundColor: Colors.red,
                                      ));
                                    }
                                  } else {
                                    // studentId равен null, обработка этого случая
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('Failed to get student ID'),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                } catch (error) {
                                  // Обработка ошибки
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Failed to create chat: $error'),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        ExpansionTile(
                          title: Text('About Trainer'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                trainer.about,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 1, color: Colors.grey),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              _serverResponse,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
