class Validators {
  static String? validateMass(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите массу';
    }
    
    final mass = double.tryParse(value);
    if (mass == null) {
      return 'Введите корректное число';
    }
    
    if (mass < 0) {
      return 'Масса не может быть отрицательной';
    }
    
    if (mass > 1000) {
      return 'Масса слишком большая';
    }
    
    return null;
  }

  static String? validateFormula(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите формулу';
    }
    
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value)) {
      return 'Формула содержит недопустимые символы';
    }
    
    return null;
  }

  static String? validateCoefficient(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите коэффициент';
    }
    
    final coefficient = int.tryParse(value);
    if (coefficient == null || coefficient <= 0) {
      return 'Коэффициент должен быть положительным числом';
    }
    
    if (coefficient > 10) {
      return 'Коэффициент слишком большой';
    }
    
    return null;
  }
}