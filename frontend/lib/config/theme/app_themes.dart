import 'package:flutter/material.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Off-white premium bg
    primaryColor: const Color(0xFF8B37FF), // Purple accent
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xFF8B37FF),
      secondary: const Color(0xFF8B37FF),
    ),
    fontFamily: 'Muli',
    appBarTheme: appBarTheme(),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    backgroundColor: Color(0xFFF8F9FA), // Match scaffold
    elevation: 0,
    centerTitle: false, // Left aligned usually looks more modern
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 22,
      fontFamily: 'Butler',
      fontWeight: FontWeight.bold,
    ),
  );
}
