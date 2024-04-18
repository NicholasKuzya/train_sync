import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../token_manager.dart';

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
  TextEditingController _messageController = TextEditingController();
  String _serverResponse = '';

  List<Trainer> _trainers = [];

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
      Uri.parse('http://192.168.0.106:4000/api/trainer/get/all?country=$_selectedCountry&city=$_selectedCity&district=$_selectedDistrict&sortBy=$_selectedSortBy'),
      headers: {
        'authorization': token,
        'Content-Type': 'application/json'
      },
    );
    final data = json.decode(response.body);
    if (data['success']) {
      final dataTrainers = data['trainers'] as List<dynamic>;
      setState(() {
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
        Uri.parse('http://192.168.0.106:4000/api/student/training/send-request'),
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
          title: Text("Отправить запрос"),
          content: TextField(
            controller: _messageController,
            decoration: InputDecoration(labelText: "Сообщение"),
            maxLines: null, // Многострочное поле
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Отправить"),
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
        title: Text('Trainer Input'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCountry.isNotEmpty ? _selectedCountry : null,
              items: <String>['', 'Country 1', 'Country 2', 'Country 3'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.isEmpty ? 'Not Selected' : value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountry = newValue ?? '';
                  _fetchTrainers();
                });
              },
              decoration: InputDecoration(labelText: 'Country'),
            ),
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
                                  trainer.avatarUrl,
                                  fit: BoxFit.cover,
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
                              onPressed: () {
                                // Действие по отправке сообщения в чат
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