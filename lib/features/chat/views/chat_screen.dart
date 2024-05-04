import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../token_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String companionId;

  ChatScreen({required this.chatId, required this.companionId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  List<ChatMessage> _messages = [];
  late String _senderId = '';
  dynamic _companionData;
  late TextEditingController _messageController =
      TextEditingController(); // Инициализируем контроллер здесь

  @override
  void initState() {
    super.initState();
    _messageController =
        TextEditingController(); // Инициализируем контроллер сообщений

    // Подключение к серверу
    socket = IO.io('http://192.168.0.105:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Подписка на событие получения сообщения
    socket.on('message', (data) {
      print('Message received: $data');
      // Обновление списка сообщений и UI с новым сообщением
      setState(() {
        _messages.add(ChatMessage.fromJson(
            data)); // Предполагается, что на сервере сообщение приходит как JSON объект
      });
      // Прокручиваем к последнему сообщению при получении нового сообщения
      _scrollToBottom();
    });

    // Подключение к серверу
    socket.connect();

    // Получение идентификатора отправителя
    _getSenderId();

    // получение объекта собеседника
    _getCompanionData();
    // Получение сообщений чата
    _fetchChatMessages();
  }
  // Метод для прослушивания новых сообщений
  void _listenToNewMessages() {
    socket.on('message', (data) {
      ChatMessage newMessage = ChatMessage.fromJson(data);

      // Проверяем, пришло ли новое сообщение от текущего собеседника
      if (newMessage.senderId == _companionData['_id'] || newMessage.senderId == _senderId) {

        // Обновляем список сообщений и прокручиваем к последнему
        setState(() {
          _messages.add(newMessage);
        });
        _scrollToBottom();
      }
    });
  }
  // Метод для получения идентификатора отправителя
  Future<void> _getSenderId() async {
    String? token = await TokenManager.getToken();
    if (token == null) {
      return;
    }
    String? role = await TokenManager.getRole();
    var url = Uri.parse('http://192.168.0.105:4000/api/$role/get');
    var response = await http.post(
      url,
      headers: {'authorization': '$token'},
    );
    var data = json.decode(response.body);
    if (data != null && data['success'] == true) {
      print(data);
      if (data['$role'] != null && data['$role']['_id'] != null) {
        print(data['$role']['_id']);
        setState(() {
          _senderId = data['$role']['_id'];
        });
        // Присоединение к комнате чата при входе в чат
        socket.emit('joinChat', widget.chatId);
      }
    }
  }

  Future<void> _getCompanionData() async {
    String? token = await TokenManager.getToken();
    if (token == null) {
      return;
    }
    String? role = await TokenManager.getRole();
    if (role == "trainer") {
      role = "student";
    } else if (role == "student") {
      role = "trainer";
    }
    var url = Uri.parse(
        'http://192.168.0.105:4000/api/$role/get/${widget.companionId}');
    var response = await http.post(
      url,
      headers: {'authorization': '$token'},
    );
    var data = json.decode(response.body);
    if (data != null && data['success'] == true) {
      if (data['$role'] != null && data['$role']['_id'] != null) {
        setState(() {
          _companionData = data['$role'];
        });
      }
    }
  }

  // Метод для отправки сообщения на сервер
  void sendMessage(String message, TextEditingController messageController) {
    if (_senderId.isEmpty) {
      // Если идентификатор отправителя не получен, не отправляем сообщение
      return;
    }
    socket.emit('sendMessage', {
      'chatId': widget.chatId,
      'message': message,
      'recipient': widget.companionId,
      'sender': _senderId,
    });

    // Очищаем поле ввода сообщения после отправки
    messageController.clear();

    // Добавляем новое сообщение в список сообщений и прокручиваем к последнему сообщению
    setState(() {
      _messages.add(ChatMessage(
          senderId: _senderId, message: message, timestamp: DateTime.now()));
    });
    _scrollToBottom();
  }

  // Метод для получения сообщений чата
  Future<void> _fetchChatMessages() async {
    try {
      String? token = await TokenManager.getToken();
      var url = Uri.parse('http://192.168.0.105:4000/api/chat/messages');
      var response = await http.post(
        url,
        headers: {
          'authorization': '$token',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'chatId': widget.chatId,
        }),
      );
      var data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _messages = List<ChatMessage>.from(
              data['messages'].map((x) => ChatMessage.fromJson(x)));
        });
        // Прокручиваем к последнему сообщению при получении сообщений
        _scrollToBottom();
      } else {
        // Обработка ошибки
      }
    } catch (error) {
      // Обработка ошибки
    }
  }

  // Метод для прокрутки к последнему сообщению в списке
  void _scrollToBottom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  // Контроллер для прокрутки списка
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (BuildContext context) {
            if (_companionData != null) {
              return GestureDetector(
                onTap: () {
                  // Перейти на страницу профиля собеседника по нажатию на весь AppBar
                  Navigator.pushNamed(
                    context,
                    '/profile/${_companionData['_id']}',
                  );
                },
                child: AppBar(
                  titleSpacing: 0.0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_companionData['fullName']),
                      CircleAvatar(
                        radius: 20,
                        child: ClipOval(
                          child: _companionData['avatar'] != null && _companionData['avatar']['src'].isNotEmpty &&
                              _companionData['avatar']['src'] != ""
                              ? Image.network(
                            _companionData['avatar']['src'],
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.person),
                        ),
                      ),
                    ],
                  ),
                  actions: [],
                ),
              );
            } else {
              // Если данные о собеседнике еще не загружены, отображаем заглушку
              return AppBar(title: Text("Loading..."));
            }
          },
        ),
      ),
      body: ChatBody(
          messages: _messages,
          sendMessage: sendMessage,
          senderId: _senderId,
          controller: _controller,
          messageController: _messageController),
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
  final void Function(String, TextEditingController) sendMessage;
  final String senderId;
  final ScrollController controller;
  final TextEditingController
      messageController; // Добавляем контроллер сообщений

  ChatBody(
      {required this.messages,
      required this.sendMessage,
      required this.senderId,
      required this.controller,
      required this.messageController});

  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            controller: widget.controller,
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              ChatMessage message = widget.messages[index];
              bool isSentByMe = message.senderId == widget.senderId;
              return Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (index == 0 ||
                      widget.messages[index - 1].timestamp.day !=
                          message.timestamp.day)
                    Center(
                      child: Text(
                        '${_getFormattedDate(message.timestamp)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                      color: isSentByMe ? Colors.blue : Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: isSentByMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.message,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .fontSize! -
                                2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${message.timestamp.toLocal().hour}:${_twoDigits(message.timestamp.toLocal().minute)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .fontSize! -
                                4,
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
                  controller: widget.messageController,
                  decoration: InputDecoration(
                    hintText: '${AppLocalizations.of(context)!.enter_message}...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (widget.messageController.text.isNotEmpty) {
                    widget.sendMessage(widget.messageController.text,
                        widget.messageController);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getFormattedDate(DateTime dateTime) {
    return '${dateTime.day} ${_getMonthName(dateTime.month)}';
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return AppLocalizations.of(context)!.january;
      case 2:
        return AppLocalizations.of(context)!.february;
      case 3:
        return AppLocalizations.of(context)!.march;
      case 4:
        return AppLocalizations.of(context)!.april;
      case 5:
        return AppLocalizations.of(context)!.may;
      case 6:
        return AppLocalizations.of(context)!.june;
      case 7:
        return AppLocalizations.of(context)!.july;
      case 8:
        return AppLocalizations.of(context)!.august;
      case 9:
        return AppLocalizations.of(context)!.september;
      case 10:
        return AppLocalizations.of(context)!.october;
      case 11:
        return AppLocalizations.of(context)!.november;
      case 12:
        return AppLocalizations.of(context)!.december;
      default:
        return '';
    }
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}

class ChatMessage {
  final String senderId;
  final String message;
  final DateTime timestamp;

  ChatMessage(
      {required this.senderId, required this.message, required this.timestamp});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['sender'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
