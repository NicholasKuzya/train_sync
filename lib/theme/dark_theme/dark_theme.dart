import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1B85F3),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey; // Цвет фона для неактивной кнопки
          }
          return Color(0xFF1B85F3); // Голубой цвет для активной кнопки
        },
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0), // Радиус кнопки
        ),
      ),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(vertical: 17.0), // Отступы сверху и снизу
      ),
      textStyle: MaterialStateProperty.all<TextStyle>(
        TextStyle(
          fontSize: 14.0, // Размер текста
          fontWeight: FontWeight.w600, // Жирность текста
          color: Colors.white, // Цвет текста для активной кнопки
        ),
      ),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Цвет текста для всех состояний кнопки
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
// Цвет фона для текстовой кнопки
          return Colors.white; // Белый цвет
        },
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
        Color(0xFF1B85F3), // Цвет текста для активной кнопки
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        Color(0xFFF5BA41), // Цвет фона для оранжевой кнопки
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
        Colors.white, // Белый цвет текста для оранжевой кнопки
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0), // Радиус кнопки
        ),
      ),
      textStyle: MaterialStateProperty.all<TextStyle>(
        TextStyle(
          fontSize: 14.0, // Размер текста
          fontWeight: FontWeight.w700,// Жирность текста
        ),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(width: 1.0, color: Color(0xFFD9DFE6)),
      borderRadius: BorderRadius.circular(14.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2.0, color: Color(0xFFD1E6FF)),
      borderRadius: BorderRadius.circular(14.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1.0, color: Color(0xFFD9DFE6)),
      borderRadius: BorderRadius.circular(14.0),
    ),
    contentPadding: EdgeInsets.all(12.0),
    hintStyle: TextStyle(fontSize: 14.0),
    labelStyle: TextStyle(color: Color(0xFF39434F), fontSize: 14.0),
  ),
  dividerColor: Colors.white.withOpacity(0.8),
  listTileTheme: const ListTileThemeData(iconColor: Color(0xFF39434F)),
  textTheme: TextTheme(
    bodyMedium: const TextStyle(
      color: Color(0xFF39434F),
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    labelSmall: TextStyle(
      color: Colors.white.withOpacity(0.6),
      fontWeight: FontWeight.w700,
      fontSize: 14,
    ),
  ),
);
