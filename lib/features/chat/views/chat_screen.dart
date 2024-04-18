import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../token_manager.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String studentId;

  ChatScreen({required this.chatId, required this.studentId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  List<ChatMessage> _messages = []; // Список сообщений чата
  late String _senderId = ''; // Идентификатор отправителя

  @override
  void initState() {
    super.initState();

    // Подключение к серверу
    socket = IO.io('http://192.168.0.106:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Подписка на событие получения сообщения
    socket.on('message', (data) {
      print('Message received: $data');
      // Обновление списка сообщений и UI с новым сообщением
      setState(() {
        _messages.add(ChatMessage.fromJson(data)); // Предполагается, что на сервере сообщение приходит как JSON объект
      });
    });

    // Подключение к серверу
    socket.connect();

    // Получение идентификатора отправителя
    _getSenderId();

    // Получение сообщений чата
    _fetchChatMessages();
  }

  // Метод для получения идентификатора отправителя
  Future<void> _getSenderId() async {
    String? token = await TokenManager.getToken();
    if (token == null) {
      return;
    }
    String? role = await TokenManager.getRole();
    var url = Uri.parse('http://192.168.0.106:4000/api/$role/get');
    var response = await http.post(
      url,
      headers: {'authorization': '$token'},
    );
    var data = json.decode(response.body);
    if (data != null && data['success'] == true) {
      print(data);
      if (data['trainer'] != null && data['trainer']['_id'] != null) {
        print(data['trainer']['_id']);
        setState(() {
          _senderId = data['trainer']['_id'];
        });
        // Присоединение к комнате чата при входе в чат
        socket.emit('joinChat', widget.chatId);
      }
    }
  }

  // Метод для отправки сообщения на сервер
  void sendMessage(String message) {
    if (_senderId.isEmpty) {
      // Если идентификатор отправителя не получен, не отправляем сообщение
      return;
    }
    socket.emit('sendMessage', {
      'chatId': widget.chatId,
      'message': message,
      'recipient': widget.studentId,
      'sender': _senderId,
    });

    // Добавление нового сообщения в список сообщений и обновление UI
    setState(() {
      _messages.add(ChatMessage(
        senderId: _senderId,
        message: message,
        timestamp: DateTime.now(),
      ));
    });
  }

  // Метод для получения сообщений чата
  Future<void> _fetchChatMessages() async {
    try {
      String? token = await TokenManager.getToken();
      var url = Uri.parse('http://192.168.0.106:4000/api/chat/messages');
      var response = await http.post(
        url,
        headers: {'authorization': '$token', 'Content-Type': 'application/json'},
        body: json.encode({
          'chatId': widget.chatId,
        }),
      );
      var data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _messages = List<ChatMessage>.from(data['messages'].map((x) => ChatMessage.fromJson(x)));
        });
      } else {
        // Обработка ошибки
      }
    } catch (error) {
      // Обработка ошибки
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Чат ${widget.chatId}'),
      ),
      body: ChatBody(messages: _messages, sendMessage: sendMessage, senderId: _senderId),
    );
  }

  @override
  void dispose() {
    // Отключение от сервера при закрытии экрана
    socket.disconnect();
    super.dispose();
  }
}

class ChatBody extends StatefulWidget {
  final List<ChatMessage> messages; // Список сообщений чата
  final void Function(String) sendMessage;
  final String senderId; // Идентификатор отправителя

  ChatBody({required this.messages, required this.sendMessage, required this.senderId});

  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              ChatMessage message = widget.messages[index];
              bool isSentByMe = message.senderId == widget.senderId;
              return Column(
                crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (index == 0 || widget.messages[index - 1].timestamp.day != message.timestamp.day)
                  // Показываем день и месяц, если это первое сообщение или день изменился
                    Center(
                      child: Text(
                        '${_getFormattedDate(message.timestamp)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    width: MediaQuery.of(context).size.width / 2, // Ширина равна половине ширины экрана
                    decoration: BoxDecoration(
                      color: isSentByMe ? Colors.blue : Colors.green, // Цвет фона в зависимости от отправителя
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.message,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Theme.of(context).textTheme.bodyText1!.fontSize! - 2, // Уменьшаем шрифт на 2 пикселя
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${message.timestamp.hour}:${_twoDigits(message.timestamp.minute)}', // Отображаем время
                          style: TextStyle(
                            color: Colors.grey, // Цвет времени серый
                            fontSize: Theme.of(context).textTheme.bodyText1!.fontSize! - 4, // Уменьшаем размер шрифта времени
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Введите сообщение...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    widget.sendMessage(_messageController.text);
                    _messageController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Метод для форматирования даты в нужный формат (день и месяц)
  String _getFormattedDate(DateTime dateTime) {
    return '${dateTime.day} ${_getMonthName(dateTime.month)}';
  }

  // Метод для получения названия месяца по его номеру
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'января';
      case 2:
        return 'февраля';
      case 3:
        return 'марта';
      case 4:
        return 'апреля';
      case 5:
        return 'мая';
      case 6:
        return 'июня';
      case 7:
        return 'июля';
      case 8:
        return 'августа';
      case 9:
        return 'сентября';
      case 10:
        return 'октября';
      case 11:
        return 'ноября';
      case 12:
        return 'декабря';
      default:
        return '';
    }
  }

  // Метод для преобразования числа в строку с двумя цифрами (добавляет ведущий ноль, если число меньше 10)
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String senderId;
  final String message;
  final DateTime timestamp; // Добавляем временную метку для сообщения

  ChatMessage({required this.senderId, required this.message, required this.timestamp});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['sender'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']), // Преобразуем строку времени в объект DateTime
    );
  }
}
