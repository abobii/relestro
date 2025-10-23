import 'package:flutter/material.dart';
import '../../models/flask.dart';
import '../../models/quest.dart';
import '../../models/substance.dart';
import '../../models/chemical_reaction.dart';
import '../../services/game_manager.dart';
import '../../services/reaction_service.dart';
import '../../utils/color_palette.dart';
import '../../utils/chemistry_calculator.dart';
import '../common/animated_button.dart';
import '../common/flask_widget.dart';
import '../particles/liquid_animation.dart';

class LabScreen extends StatefulWidget {
  final Quest quest;
  final GameManager gameManager;
  final VoidCallback onQuestCompleted;

  const LabScreen({
    super.key,
    required this.quest,
    required this.gameManager,
    required this.onQuestCompleted,
  });

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  final Map<int, double> _reagentMasses = {};
  final Map<int, TextEditingController> _massControllers = {};
  final ReactionService _reactionService = ReactionService();
  bool _isReactionInProgress = false;
  String _reactionResult = '';
  double _producedMass = 0.0;
  bool _showSuccessAnimation = false;

  @override
  void initState() {
    super.initState();
    _initializeReagents();
  }

  @override
  void dispose() {
    for (final controller in _massControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeReagents() {
    for (final reagentId in widget.quest.getAvailableReagentIds()) {
      _reagentMasses[reagentId] = 0.0;
      _massControllers[reagentId] = TextEditingController(text: '0.0');
    }
  }

  List<Substance> get _availableReagents {
    return widget.quest.getAvailableReagentIds().map((id) {
      return widget.gameManager.getSubstanceById(id)!;
    }).toList();
  }

  Substance get _targetSubstance {
    return widget.gameManager.getSubstanceById(widget.quest.targetSubstanceId)!;
  }

  void _updateMass(int substanceId, String value) {
    final mass = double.tryParse(value) ?? 0.0;
    setState(() {
      _reagentMasses[substanceId] = mass;
    });
  }

  bool get _canStartReaction {
    return _reagentMasses.values.any((mass) => mass > 0) && !_isReactionInProgress;
  }

  void _performReaction() {
    if (!_canStartReaction) return;

    setState(() {
      _isReactionInProgress = true;
      _reactionResult = '';
      _showSuccessAnimation = false;
    });

    // Имитация процесса реакции
    Future.delayed(const Duration(seconds: 2), () {
      _calculateReactionResult();
    });
  }

  void _calculateReactionResult() {
    print('=== DEBUG LAB SCREEN ===');
    print('Input masses: $_reagentMasses');
    
    try {
      // Получаем реакцию для текущего квеста
      final reaction = _getReactionForQuest();
      
      // Собираем все вещества (реагенты + целевое вещество)
      final substances = [..._availableReagents, _targetSubstance];
      
      // Конвертируем ID в формулы для масс
      final inputMasses = <String, double>{};
      for (final reagent in _availableReagents) {
        final mass = _reagentMasses[reagent.substanceId] ?? 0.0;
        if (mass > 0) {
          inputMasses[reagent.formula] = mass;
        }
      }
      
      print('Reaction: ${reaction.reactionString}');
      print('Input masses (formulas): $inputMasses');
      print('Substances: ${substances.map((s) => s.formula).toList()}');
      
      // Используем настоящий ReactionService для точных расчетов
      final result = _reactionService.performReaction(
        reaction: reaction,
        inputMasses: inputMasses,
        allSubstances: substances,
      );
      
      print('Reaction result: ${result.productMasses}');
      print('Reaction success: ${result.success}');
      print('Limiting reagent: ${result.limitingReagent}');
      
      if (result.success) {
        // Берем массу целевого вещества из результатов реакции
        _producedMass = result.productMasses[_targetSubstance.formula] ?? 0.0;
      } else {
        // Если реакция не удалась, используем упрощенный расчет
        final totalMass = _reagentMasses.values.reduce((a, b) => a + b);
        _producedMass = totalMass * _getReactionEfficiency();
        print('Reaction failed, using fallback: $_producedMass');
      }
      
    } catch (e, stackTrace) {
      print('Error in reaction calculation: $e');
      print('Stack trace: $stackTrace');
      // Fallback на старую логику при ошибке
      final totalMass = _reagentMasses.values.reduce((a, b) => a + b);
      _producedMass = totalMass * _getReactionEfficiency();
    }
    
    print('Produced mass: $_producedMass');
    print('Target: ${widget.quest.targetAmount}');
    print('=======================');
    
    final isSuccess = (_producedMass - widget.quest.targetAmount).abs() <= 5.0;
    
    setState(() {
      _isReactionInProgress = false;
      _reactionResult = isSuccess ? 'success' : 'partial';
      
      if (isSuccess) {
        _showSuccessAnimation = true;
        widget.gameManager.completeQuest(widget.quest.questId);
        widget.onQuestCompleted();
      }
    });

    if (isSuccess) {
      Future.delayed(const Duration(seconds: 2), () {
        _showSuccessDialog();
      });
    }
  }

  ChemicalReaction _getReactionForQuest() {
    // Сопоставляем questId с reactionId
    switch (widget.quest.questId) {
      case 1: // Синтез воды
        return ChemicalReaction(
          reactionId: 1,
          reactionString: '2H₂ + O₂ → 2H₂O',
          reactants: 'H2:2,O2:1',
          products: 'H2O:2',
          balancedCoefficients: '2,1,2',
        );
      case 2: // Получение CO₂
        return ChemicalReaction(
          reactionId: 2,
          reactionString: 'C + O₂ → CO₂',
          reactants: 'C:1,O2:1',
          products: 'CO2:1',
          balancedCoefficients: '1,1,1',
        );
      case 3: // Сжигание метана
        return ChemicalReaction(
          reactionId: 3,
          reactionString: 'CH₄ + 2O₂ → CO₂ + 2H₂O',
          reactants: 'CH4:1,O2:2',
          products: 'CO2:1,H2O:2',
          balancedCoefficients: '1,2,1,2',
        );
      default:
        throw Exception('Unknown quest ID: ${widget.quest.questId}');
    }
  }

  double _getReactionEfficiency() {
    // Эффективность зависит от точности масс (используется как fallback)
    final recommendedMasses = _getRecommendedMasses();
    double efficiency = 0.8; // Базовая эффективность
    
    for (final reagent in _availableReagents) {
      final actualMass = _reagentMasses[reagent.substanceId] ?? 0;
      final recommendedMass = recommendedMasses[reagent.substanceId] ?? 0;
      
      if (recommendedMass > 0) {
        final ratio = actualMass / recommendedMass;
        if (ratio >= 0.9 && ratio <= 1.1) {
          efficiency += 0.1;
        } else if (ratio >= 0.7 && ratio <= 1.3) {
          efficiency += 0.05;
        }
      }
    }
    
    return efficiency.clamp(0.5, 0.95);
  }

  Map<int, double> _getRecommendedMasses() {
    final recommended = <int, double>{};
    
    switch (widget.quest.questId) {
      case 1: // Синтез воды
        recommended[1] = 4.04; // Водород
        recommended[2] = 32.0; // Кислород
        break;
      case 2: // Получение CO₂
        recommended[4] = 12.01; // Углерод
        recommended[2] = 32.0;  // Кислород
        break;
      case 3: // Сжигание метана
        recommended[6] = 32.08; // Метан (для 88.02 г CO₂)
        recommended[2] = 128.0; // Кислород (для 88.02 г CO₂)
        break;
    }
    
    return recommended;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.green),
            SizedBox(width: 8),
            Text('Эксперимент успешен!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Вы получили ${_producedMass.toStringAsFixed(2)} г ${_targetSubstance.name}'),
            const SizedBox(height: 8),
            Text('Цель: ${widget.quest.targetAmount} г'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text('+${widget.quest.rewardPoints} очков'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Возврат к списку заданий
            },
            child: const Text('Продолжить'),
          ),
        ],
      ),
    );
  }

  void _showReactionTheory() {
    final theory = _getReactionTheory();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Теория реакции'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                theory['equation']!.first,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Стехиометрические соотношения:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...(theory['ratios'] as List<String>).map((ratio) => Text('• $ratio')),
              const SizedBox(height: 16),
              const Text(
                'Рекомендуемые массы:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._availableReagents.map((reagent) {
                final recommended = _getRecommendedMasses()[reagent.substanceId];
                return Text('• ${reagent.name}: ${recommended?.toStringAsFixed(2)} г');
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _getReactionTheory() {
    switch (widget.quest.questId) {
      case 1:
        return {
          'equation': ['2H₂ + O₂ → 2H₂O'],
          'ratios': [
            '2 моль H₂ : 1 моль O₂ : 2 моль H₂O',
            '4.04 г H₂ : 32 г O₂ : 36.04 г H₂O',
          ],
        };
      case 2:
        return {
          'equation': ['C + O₂ → CO₂'],
          'ratios': [
            '1 моль C : 1 моль O₂ : 1 моль CO₂',
            '12.01 г C : 32 г O₂ : 44.01 г CO₂',
          ],
        };
      case 3:
        return {
          'equation': ['CH₄ + 2O₂ → CO₂ + 2H₂O'],
          'ratios': [
            '1 моль CH₄ : 2 моль O₂ : 1 моль CO₂ : 2 моль H₂O',
            '32.08 г CH₄ : 128 г O₂ : 88.02 г CO₂ : 72.08 г H₂O',
          ],
        };
      default:
        return {
          'equation': ['Реакция'],
          'ratios': ['Проведите эксперимент'],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quest.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isReactionInProgress ? null : () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _showReactionTheory,
            tooltip: 'Теория реакции',
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Описание задания
                _buildQuestInfo(),
                
                const SizedBox(height: 20),
                
                // Реагенты
                const Text(
                  'Реагенты:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                
                const SizedBox(height: 12),
                
                // Список реагентов
                Expanded(
                  child: _buildReagentsList(),
                ),
                
                const SizedBox(height: 16),
                
                // Результат реакции
                if (_reactionResult.isNotEmpty) _buildReactionResult(),
                
                const SizedBox(height: 16),
                
                // Кнопка начала реакции
                _buildReactionButton(),
              ],
            ),
          ),
          
          // Анимация успеха
          if (_showSuccessAnimation)
            const Center(
              child: LiquidAnimation(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.quest.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Цель: ${widget.quest.targetAmount} г ${_targetSubstance.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReagentsList() {
    return ListView.builder(
      itemCount: _availableReagents.length,
      itemBuilder: (context, index) {
        final reagent = _availableReagents[index];
        return _buildReagentCard(reagent);
      },
    );
  }

  Widget _buildReagentCard(Substance reagent) {
    final currentMass = _reagentMasses[reagent.substanceId] ?? 0.0;
    final controller = _massControllers[reagent.substanceId]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о реагенте
            Row(
              children: [
                // FlaskWidget вместо иконки
                FlaskWidget(
                  flask: Flask(
                    id: reagent.substanceId.toString(),
                    imagePath: '',
                    color: AppColors.getSubstanceColor(reagent.formula),
                    maxVolume: 100,
                    currentVolume: currentMass.clamp(0, 100),
                    substanceFormula: reagent.formula,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reagent.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        reagent.formula,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Молярная масса: ${reagent.molarMass} г/моль',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Поле ввода массы
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Масса реагента (г)',
                border: OutlineInputBorder(),
                suffixText: 'г',
              ),
              onChanged: (value) => _updateMass(reagent.substanceId, value),
            ),
            
            // Текущая масса
            if (currentMass > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Текущая масса: ${currentMass.toStringAsFixed(2)} г',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReactionResult() {
    final isSuccess = _reactionResult == 'success';
    
    return Card(
      color: isSuccess ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info,
              color: isSuccess ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSuccess ? 'Реакция прошла успешно!' : 'Реакция завершена',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Получено ${_producedMass.toStringAsFixed(2)} г ${_targetSubstance.name}',
                  ),
                  if (!isSuccess) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Попробуйте другие соотношения реагентов',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton() {
    return AnimatedButton(
      onPressed: _canStartReaction ? _performReaction : null,
      backgroundColor: _canStartReaction ? AppColors.success : Colors.grey,
      child: _isReactionInProgress
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Реакция идет...',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.science, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Начать реакцию',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
    );
  }
}