import 'package:flutter/material.dart';
import '../utils/color_palette.dart';

final ThemeData darkThemeData = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: AppColors.primary,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  
);