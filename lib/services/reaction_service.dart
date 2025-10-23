
import '../models/chemical_reaction.dart';
import '../models/substance.dart';
import '../models/reaction_result.dart';
import '../utils/chemistry_calculator.dart';

class ReactionService {
  
  ReactionResult performReaction({
    required ChemicalReaction reaction,
    required Map<String, double> inputMasses,
    required List<Substance> allSubstances,
  }) {
    try {
      // Парсим коэффициенты
      final coefficients = _parseCoefficients(reaction.balancedCoefficients);
      final reactants = _parseCompounds(reaction.reactants);
      final products = _parseCompounds(reaction.products);

      // Находим лимитирующий реагент
      final limitingReagent = ChemistryCalculator.findLimitingReagent(
        inputMasses,
        reactants,
      );

      if (limitingReagent.isEmpty) {
        return ReactionResult(
          success: false,
          message: 'Недостаточно реагентов для реакции',
          productMasses: {},
          remainingMasses: {},
        );
      }

      // Рассчитываем продукты
      final productMasses = _calculateProductMasses(
        limitingReagent,
        inputMasses[limitingReagent]!,
        reactants,
        products,
        coefficients,
        allSubstances,
      );

      // Рассчитываем остатки
      final remainingMasses = _calculateRemainingMasses(
        inputMasses,
        limitingReagent,
        inputMasses[limitingReagent]!,
        reactants,
        coefficients,
        allSubstances,
      );

      // Проверяем эффективность
      final efficiency = _calculateEfficiency(inputMasses, reactants);

      return ReactionResult(
        success: true,
        message: 'Реакция прошла успешно! Лимитирующий реагент: $limitingReagent',
        productMasses: productMasses,
        remainingMasses: remainingMasses,
        limitingReagent: limitingReagent,
        efficiency: efficiency,
      );

    } catch (e) {
      return ReactionResult(
        success: false,
        message: 'Ошибка при выполнении реакции: $e',
        productMasses: {},
        remainingMasses: {},
      );
    }
  }

  Map<String, double> _calculateProductMasses(
    String limitingReagent,
    double limitingMass,
    Map<String, int> reactants,
    Map<String, int> products,
    List<int> coefficients,
    List<Substance> allSubstances,
  ) {
    final productMasses = <String, double>{};
    final limitingIndex = _getCompoundIndex(limitingReagent, reactants);
    
    for (final product in products.entries) {
      final productFormula = product.key;
      final productSubstance = allSubstances.firstWhere(
        (s) => s.formula == productFormula
      );
      
      final productCoefficient = coefficients[reactants.length + _getCompoundIndex(productFormula, products)];
      final limitingCoefficient = coefficients[limitingIndex];
      
      final mass = ChemistryCalculator.calculateProductMass(
        reagentMass: limitingMass,
        reagentMolarMass: _getMolarMass(limitingReagent, allSubstances),
        productMolarMass: productSubstance.molarMass,
        reagentCoefficient: limitingCoefficient,
        productCoefficient: productCoefficient,
      );
      
      productMasses[productFormula] = double.parse(mass.toStringAsFixed(2));
    }
    
    return productMasses;
  }

  Map<String, double> _calculateRemainingMasses(
    Map<String, double> inputMasses,
    String limitingReagent,
    double limitingMass,
    Map<String, int> reactants,
    List<int> coefficients,
    List<Substance> allSubstances,
  ) {
    final remainingMasses = <String, double>{};
    final limitingIndex = _getCompoundIndex(limitingReagent, reactants);
    
    for (final reactant in reactants.entries) {
      final formula = reactant.key;
      if (formula == limitingReagent) {
        remainingMasses[formula] = 0.0;
        continue;
      }
      
      final reactantCoefficient = coefficients[_getCompoundIndex(formula, reactants)];
      final limitingCoefficient = coefficients[limitingIndex];
      
      final expectedMass = (limitingMass / _getMolarMass(limitingReagent, allSubstances)) * 
          (reactantCoefficient / limitingCoefficient) * 
          _getMolarMass(formula, allSubstances);
      
      final remaining = (inputMasses[formula] ?? 0) - expectedMass;
      remainingMasses[formula] = remaining > 0 ? double.parse(remaining.toStringAsFixed(2)) : 0.0;
    }
    
    return remainingMasses;
  }

  double _calculateEfficiency(Map<String, double> inputMasses, Map<String, int> reactants) {
    // Упрощенный расчет эффективности на основе баланса масс
    final ratios = <double>[];
    
    for (final reactant in reactants.entries) {
      if (inputMasses.containsKey(reactant.key) && inputMasses[reactant.key]! > 0) {
        ratios.add(inputMasses[reactant.key]! / reactant.value);
      }
    }
    
    if (ratios.length < 2) return 1.0;
    
    final avgRatio = ratios.reduce((a, b) => a + b) / ratios.length;
    double variance = 0.0;
    
    for (final ratio in ratios) {
      variance += (ratio - avgRatio).abs();
    }
    
    variance /= ratios.length;
    
    return (1.0 - variance / avgRatio).clamp(0.5, 1.0);
  }

  Map<String, int> _parseCompounds(String compoundsString) {
    final compounds = <String, int>{};
    final parts = compoundsString.split(',');
    
    for (final part in parts) {
      final compoundParts = part.split(':');
      if (compoundParts.length == 2) {
        compounds[compoundParts[0]] = int.parse(compoundParts[1]);
      }
    }
    
    return compounds;
  }

  List<int> _parseCoefficients(String coefficientsString) {
    return coefficientsString.split(',').map(int.parse).toList();
  }

  int _getCompoundIndex(String formula, Map<String, int> compounds) {
    return compounds.keys.toList().indexOf(formula);
  }

  double _getMolarMass(String formula, List<Substance> substances) {
    return substances.firstWhere((s) => s.formula == formula).molarMass;
  }
}