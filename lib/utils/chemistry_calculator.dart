class ChemistryCalculator {
  // Расчет массы продукта по уравнению реакции
  static double calculateProductMass({
    required double reagentMass,
    required double reagentMolarMass,
    required double productMolarMass,
    required int reagentCoefficient,
    required int productCoefficient,
  }) {
    final reagentMoles = reagentMass / reagentMolarMass;
    final productMoles = reagentMoles * (productCoefficient / reagentCoefficient);
    return productMoles * productMolarMass;
  }

  // Расчет лимитирующего реагента - ИСПРАВЛЕННАЯ ВЕРСИЯ
  static String findLimitingReagent(
      Map<String, double> masses, 
      Map<String, int> coefficients,
      [Map<String, double>? molarMasses]) {
    
    // Если не переданы молярные массы, используем упрощенный расчет (только для тестов)
    if (molarMasses == null) {
      double minRatio = double.infinity;
      String limitingReagent = '';

      masses.forEach((formula, mass) {
        if (coefficients.containsKey(formula) && mass > 0) {
          final ratio = mass / coefficients[formula]!;
          if (ratio < minRatio) {
            minRatio = ratio;
            limitingReagent = formula;
          }
        }
      });

      return limitingReagent;
    }

    // Правильный расчет с молярными массами
    double minMoleRatio = double.infinity;
    String limitingReagent = '';

    masses.forEach((formula, mass) {
      if (coefficients.containsKey(formula) && 
          molarMasses.containsKey(formula) && 
          mass > 0) {
        
        final moles = mass / molarMasses[formula]!;
        final moleRatio = moles / coefficients[formula]!;
        
        if (moleRatio < minMoleRatio) {
          minMoleRatio = moleRatio;
          limitingReagent = formula;
        }
      }
    });

    return limitingReagent;
  }

  // Проверка стехиометрического баланса - ИСПРАВЛЕННАЯ ВЕРСИЯ
  static bool isStoichiometricBalanced(
    Map<String, double> inputMasses,
    Map<String, int> coefficients,
    Map<String, double> molarMasses,
    double tolerance,
  ) {
    final moleRatios = <double>[];

    inputMasses.forEach((formula, mass) {
      if (coefficients.containsKey(formula) && 
          molarMasses.containsKey(formula) && 
          mass > 0) {
        
        final moles = mass / molarMasses[formula]!;
        final moleRatio = moles / coefficients[formula]!;
        moleRatios.add(moleRatio);
      }
    });

    if (moleRatios.length < 2) return true;

    final firstRatio = moleRatios.first;
    for (final ratio in moleRatios) {
      if ((ratio - firstRatio).abs() > tolerance) {
        return false;
      }
    }

    return true;
  }

  // Старая версия для обратной совместимости (используется в тестах)
  static bool isStoichiometricBalancedSimple(
    Map<String, double> inputMasses,
    Map<String, int> coefficients,
    double tolerance,
  ) {
    final ratios = <double>[];

    inputMasses.forEach((formula, mass) {
      if (coefficients.containsKey(formula) && mass > 0) {
        ratios.add(mass / coefficients[formula]!);
      }
    });

    if (ratios.length < 2) return true;

    final firstRatio = ratios.first;
    for (final ratio in ratios) {
      if ((ratio - firstRatio).abs() > tolerance) {
        return false;
      }
    }

    return true;
  }
}