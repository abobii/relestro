import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDark = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _isDark;

  void toggleTheme(bool isDark) {
    _isDark = isDark;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setDarkTheme() {
    _isDark = true;
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  void setLightTheme() {
    _isDark = false;
    _themeMode = ThemeMode.light;
    notifyListeners();
  }
}