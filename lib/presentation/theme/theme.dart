import 'package:flutter/material.dart';

/// Colori principali dell'app
const Color primaryColor = Color(0xFF9B111E);
const Color secondaryColor = Color(0xFF4A4A4A);
const Color tertiaryColor = Color(0xFFFFC107);

// Light Theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.light,
    secondary: secondaryColor,
    tertiary: tertiaryColor,
  ),
  scaffoldBackgroundColor: const Color(0xFFF4F4F4),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 4,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  textTheme: Typography.material2021().black.apply(
    bodyColor: Colors.grey[900],
    displayColor: Colors.grey[900],
  ),
);

// Dark Theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.dark,
    secondary: secondaryColor,
    tertiary: tertiaryColor,
  ),
  scaffoldBackgroundColor: const Color(0xFF1A1A1A),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 4,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  textTheme: Typography.material2021().white.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
);

