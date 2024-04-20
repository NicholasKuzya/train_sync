import 'package:app2/features/gallery/views/gallery_screen.dart';
import 'package:app2/features/profile/views/edit_profile_screen.dart';
import 'package:app2/features/profile/views/profile_screen.dart';
import 'package:app2/features/requests/views/requests_screen.dart';
import 'package:app2/features/students/views/students_screen.dart';
import 'package:app2/features/trainers/views/trainers_screen.dart';
import '../features/home/home.dart';
import '../features/authentication/registration/registration.dart';
import '../features/authentication/login/login.dart';

final routes = {
  '/': (context) => HomeScreen(),
  '/signin': (context) => SigninScreen(),
  '/login': (context) => LoginScreen(),
  '/profile': (context) => ProfileScreen(),
  '/profile/edit': (context) => EditProfileScreen(),
  '/students' : (context) => StudentScreen(),
  '/requests': (context) => RequestsScreen(),
  '/trainers': (context) => TrainerInputScreen(),
  '/gallery' : (context) => GalleryScreen()
};
