import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF005AA9),
      primary: const Color(0xFF005AA9),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF7F8FA), // фон поля
      floatingLabelStyle: const TextStyle(color: Color(0xFF005AA9)), // label при фокусе
      hintStyle: const TextStyle(color: Color(0xFFA0A5B9)), // серый placeholder
      labelStyle: const TextStyle(color: Color(0xFFA0A5B9)), // label по умолчанию — серый
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF005AA9), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFF005AA9);
          }
          return const Color(0xFF2E3A59);
        }),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 14),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF005AA9),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
  );
}
