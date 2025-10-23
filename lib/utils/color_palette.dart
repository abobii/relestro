import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  
  static const Color secondary = Color(0xFFFFA000);
  static const Color secondaryDark = Color(0xFFF57C00);
  
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);
  
  // Цвета веществ
  static const Color hydrogen = Color(0xFF90CAF9);
  static const Color oxygen = Color(0xFFEF5350);
  static const Color water = Color(0xFF81D4FA);
  static const Color carbon = Color(0xFF78909C);
  static const Color co2 = Color(0xFFFFB74D);
  static const Color methane = Color(0xFF66BB6A);
  
  static Color getSubstanceColor(String formula) {
    switch (formula) {
      case 'H2': return hydrogen;
      case 'O2': return oxygen;
      case 'H2O': return water;
      case 'C': return carbon;
      case 'CO2': return co2;
      case 'CH4': return methane;
      default: return primary;
    }
  }
}