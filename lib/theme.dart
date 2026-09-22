import 'package:flutter/material.dart';

class NexoColors {
  static const background = Color(0xFFF7F7F8);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF111111);
  static const muted = Color(0xFF6B6B6B);
  static const line = Color(0xFFE6E6E8);
  static const accent = Color(0xFFE11D2E);
}

ThemeData buildNexoTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: NexoColors.accent,
      onPrimary: Colors.white,
      surface: NexoColors.surface,
      onSurface: NexoColors.text,
    ),
    scaffoldBackgroundColor: NexoColors.background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: NexoColors.surface,
      foregroundColor: NexoColors.text,
      centerTitle: false,
    ),
    dividerColor: NexoColors.line,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: NexoColors.text,
      displayColor: NexoColors.text,
    ),
  );
}
