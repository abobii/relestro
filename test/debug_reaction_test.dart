// test/debug_reaction_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chemistry_simulator/services/reaction_service.dart';
import 'package:chemistry_simulator/models/chemical_reaction.dart';
import 'package:chemistry_simulator/models/substance.dart';

void main() {
  test('Debug methane combustion', () {
    final service = ReactionService();
    
    final reaction = ChemicalReaction(
      reactionId: 3,
      reactionString: 'CH₄ + 2O₂ → CO₂ + 2H₂O',
      reactants: 'CH4:1,O2:2',
      products: 'CO2:1,H2O:2', 
      balancedCoefficients: '1,2,1,2',
    );

    final substances = [
      Substance(substanceId: 6, name: 'Метан', formula: 'CH4', molarMass: 16.04, description: ''),
      Substance(substanceId: 2, name: 'Кислород', formula: 'O2', molarMass: 32.00, description: ''),
      Substance(substanceId: 5, name: 'CO2', formula: 'CO2', molarMass: 44.01, description: ''),
      Substance(substanceId: 3, name: 'Вода', formula: 'H2O', molarMass: 18.02, description: ''),
    ];

    final result = service.performReaction(
      reaction: reaction,
      inputMasses: {'CH4': 32.08, 'O2': 128.00},
      allSubstances: substances,
    );

    print('=== ДЕТАЛЬНЫЙ РЕЗУЛЬТАТ ===');
    print('Успех: ${result.success}');
    print('Сообщение: ${result.message}');
    print('Продукты: ${result.productMasses}');
    print('Остатки: ${result.remainingMasses}');
    print('Эффективность: ${result.efficiency}');
    print('CO2 масса: ${result.productMasses["CO2"]}');
    print('Ожидалось CO2: 88.02');
    print('===========================');

    expect(result.productMasses['CO2'], closeTo(88.02, 0.1));
  });
}