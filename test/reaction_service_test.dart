import 'package:flutter_test/flutter_test.dart';
import 'package:chemistry_simulator/services/reaction_service.dart';
import 'package:chemistry_simulator/models/chemical_reaction.dart';
import 'package:chemistry_simulator/models/substance.dart';
import 'package:chemistry_simulator/models/reaction_result.dart';

void main() {
  group('ReactionService Tests', () {
    late ReactionService reactionService;
    late List<Substance> substances;

    setUp(() {
      reactionService = ReactionService();
      substances = [
        Substance(substanceId: 1, name: 'Водород', formula: 'H2', molarMass: 2.02, description: ''),
        Substance(substanceId: 2, name: 'Кислород', formula: 'O2', molarMass: 32.00, description: ''),
        Substance(substanceId: 3, name: 'Вода', formula: 'H2O', molarMass: 18.02, description: ''),
      ];
    });

    test('should perform water synthesis reaction successfully', () {
      // Arrange
      final reaction = ChemicalReaction(
        reactionId: 1,
        reactionString: '2H₂ + O₂ → 2H₂O',
        reactants: 'H2:2,O2:1',
        products: 'H2O:2',
        balancedCoefficients: '2,1,2',
      );

      final inputMasses = {'H2': 4.04, 'O2': 32.0};

      // Act
      final result = reactionService.performReaction(
        reaction: reaction,
        inputMasses: inputMasses,
        allSubstances: substances,
      );

      // Assert
      expect(result.success, true);
      expect(result.productMasses.containsKey('H2O'), true);
      expect(result.productMasses['H2O']!, greaterThan(0));
    });

    test('should return failure for insufficient reagents', () {
      // Arrange
      final reaction = ChemicalReaction(
        reactionId: 1,
        reactionString: '2H₂ + O₂ → 2H₂O',
        reactants: 'H2:2,O2:1',
        products: 'H2O:2',
        balancedCoefficients: '2,1,2',
      );

      final inputMasses = {'H2': 0.0, 'O2': 0.0}; // No reagents

      // Act
      final result = reactionService.performReaction(
        reaction: reaction,
        inputMasses: inputMasses,
        allSubstances: substances,
      );

      // Assert
      expect(result.success, false);
      expect(result.message, contains('Недостаточно реагентов'));
    });

    test('should calculate remaining masses correctly', () {
      // Arrange
      final reaction = ChemicalReaction(
        reactionId: 1,
        reactionString: '2H₂ + O₂ → 2H₂O',
        reactants: 'H2:2,O2:1',
        products: 'H2O:2',
        balancedCoefficients: '2,1,2',
      );

      final inputMasses = {'H2': 4.04, 'O2': 40.0}; // Extra O2

      // Act
      final result = reactionService.performReaction(
        reaction: reaction,
        inputMasses: inputMasses,
        allSubstances: substances,
      );

      // Assert
      expect(result.success, true);
      expect(result.remainingMasses.containsKey('O2'), true);
      expect(result.remainingMasses['O2']!, greaterThan(0));
    });
  });
}