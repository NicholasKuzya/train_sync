import 'package:flutter/material.dart';
import '../../../token_manager.dart';

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
    Text('Galery'), // Теперь у тренера будет галерея
    Text('Profile'),
  ];

  List<Widget> _widgetOptionsForStudent = <Widget>[
    Text('Home'),
    Text('Trainers'), // Теперь у студента будет расписание тренировок
    Text('Workouts'),
    Text('Profile'),
  ];

  List<Widget> _widgetOptions = []; // Список будет инициализирован в _checkUserRole()

  Future<void> _checkUserRole() async {
    String? role = await TokenManager.getRole();
    setState(() {
      _role = role!;

      if (_role == 'student') {
        _widgetOptions = _widgetOptionsForStudent;
      } else {
        _widgetOptions = _widgetOptionsForTrainer;
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
          Navigator.pushNamed(context, '/trainers'); // Переход на экран тренеров для студента
        } else {
          Navigator.pushNamed(context, '/students'); // Переход на экран студентов для тренера
        }
        break;
      case 2:
        Navigator.pushNamed(context, _role == 'student' ? '/workouts' : '/gallery');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile'); // Переход на экран профиля
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
        title: const Text('Hello world'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          children: [
            // Sign in button with navigation
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text('Вход'), // Sign in text
            ),
            const SizedBox(height: 10.0), // Add some spacing
            // Register button with navigation
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signin'),
              child: Text('Зарегистрироваться'), // Register text
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
            label: _role == 'student' ? 'Trainers' : 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(_role == 'student' ? Icons.calendar_today : Icons.image, color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
            label: _role == 'student' ? 'Schedule' : 'Galery', // Теперь у студента "Schedule"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // Установка цвета для активного текста и иконок
        unselectedItemColor: Colors.grey, // Установка цвета для неактивного текста и иконок
      ),
    );
  }
}
