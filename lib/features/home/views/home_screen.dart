import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Text('Home'),
    Text('Students'),
    Text('Profile'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/'); // Переход на главный экран
        break;
      case 1:
        Navigator.pushNamed(context, '/students'); // Переход на экран студентов
        break;
      case 2:
        Navigator.pushNamed(context, '/profile'); // Переход на экран профиля
        break;
    }
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}