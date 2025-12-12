import 'package:flutter/material.dart';

class AppPallete {
  static const primary = Color(0xFF1E88E5);      // Blue
  static const secondary = Color(0xFFFB8C00);    // Orange
  static const background = Color(0xFFF5F5F5);   // Page background
  static const text = Color(0xFF212121);         // Dark text
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme(
    brightness: Brightness.light,

    primary: AppPallete.primary,
    onPrimary: Colors.white,

    secondary: AppPallete.secondary,
    onSecondary: Colors.white,

    surface: AppPallete.background,
    onSurface: AppPallete.text,

    error: Colors.red,
    onError: Colors.white,

    primaryContainer: AppPallete.primary,
    secondaryContainer: AppPallete.secondary,
    onPrimaryContainer: Colors.white,
    onSecondaryContainer: Colors.white,

    outline: Colors.grey,
    shadow: Colors.black,
    inverseSurface: Colors.black,
    onInverseSurface: Colors.white,
  ),

  scaffoldBackgroundColor: AppPallete.background,
);
