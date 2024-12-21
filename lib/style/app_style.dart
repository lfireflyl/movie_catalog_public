import 'package:flutter/material.dart';

class AppStyle {
  static ThemeData lightTheme() {
    return ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Color.fromARGB(255, 58, 187, 229),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.blue.shade50,
        elevation: 16.0,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(  
          color: Colors.grey[600],
          fontSize: 16,
        ),
      ),
    );
  }
}

