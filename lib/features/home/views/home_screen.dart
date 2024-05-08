import 'package:flutter/material.dart';
import '../../../token_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// AppLocalizations.of(context)!.title_home

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _role = '';

  List<Widget> _widgetOptionsForTrainer = <Widget>[
    Text('Home'),
    Text('Students'),
    Text('Gallery'), // Теперь у тренера будет галерея
    Text('Profile'),
    Text('Store')
  ];

  List<Widget> _widgetOptionsForStudent = <Widget>[
    Text('Home'),
    Text('Trainers'), // Теперь у студента будет расписание тренировок
    Text('Workouts'),
    Text('Profile'),
    Text('Store')
  ];

  List<Widget> _widgetOptions =
      []; // Список будет инициализирован в _checkUserRole()

  Future<void> _checkUserRole() async {
    String? role = await TokenManager.getRole();
    setState(() {
      if (_role != null) {
        _role = role!;
        if (_role == 'student') {
          _widgetOptions = _widgetOptionsForStudent;
        } else {
          _widgetOptions = _widgetOptionsForTrainer;
        }
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/'); // Переход на главный экран
        break;
      case 1:
        if (_role == 'student') {
          Navigator.pushNamed(
              context, '/trainers'); // Переход на экран тренеров для студента
        } else if(_role == 'trainer') {
          Navigator.pushNamed(
              context, '/students'); // Переход на экран студентов для тренера
        } else {
          Navigator.pushNamed(
              context, '/profile');
        }
        break;
      case 2:
        Navigator.pushNamed(
            context, _role == 'student' ? '/workout' : '/gallery');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile'); // Переход на экран профиля
        break;
      case 4:
        if (_role == 'student' || _role == 'trainer') {
          // Новый пункт для магазина
          Navigator.pushNamed(context, '/store'); // Переход на экран магазина
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title_home),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.welcome_message,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            RichText(
              text: TextSpan(
                text: AppLocalizations.of(context)!.test_version_message,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[800],
                ),
                children: [
                  TextSpan(
                    text: ' ${AppLocalizations.of(context)!.developer_email}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch(
                            'mailto:${AppLocalizations.of(context)!.developer_email}');
                      },
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.0),
            Text(
              AppLocalizations.of(context)!.about_app_title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              AppLocalizations.of(context)!.app_description,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
            label: AppLocalizations.of(context)!
                .home, // Используем перевод для "Home"
          ),
          if (_role == 'student' || _role == 'trainer') ...[
            BottomNavigationBarItem(
              icon: Icon(Icons.group,
                  color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
              label: _role == 'student'
                  ? AppLocalizations.of(context)!
                      .trainers // Используем перевод для "Trainers"
                  : AppLocalizations.of(context)!
                      .students, // Используем перевод для "Students"
            ),
            BottomNavigationBarItem(
              icon: Icon(
                  _role == 'student' ? Icons.calendar_today : Icons.image,
                  color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
              label: _role == 'student'
                  ? AppLocalizations.of(context)!
                      .schedule // Используем перевод для "Schedule"
                  : AppLocalizations.of(context)!
                      .gallery, // Используем перевод для "Gallery"
            ),
          ],
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
            label: AppLocalizations.of(context)!
                .profile, // Используем перевод для "Profile"
          ),
          if (_role == 'student' || _role == 'trainer')
            BottomNavigationBarItem(
              icon: Icon(Icons.store,
                  color: _selectedIndex == 4 ? Colors.blue : Colors.grey),
              label: AppLocalizations.of(context)!
                  .store, // Используем перевод для "Store"
            ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
