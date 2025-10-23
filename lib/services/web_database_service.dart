import 'package:flutter/material.dart';
import '../models/chemical_reaction.dart';
import '../models/substance.dart';
import '../models/quest.dart';
import 'progress_service.dart';

class WebDatabaseService {
  static final WebDatabaseService _instance = WebDatabaseService._internal();
  factory WebDatabaseService() => _instance;
  WebDatabaseService._internal() {
    // УБИРАЕМ вызов _initializeData() из конструктора
    // Данные будут инициализироваться при первом запросе
  }

  final List<Substance> _substances = [];
  final List<ChemicalReaction> _reactions = [];
  final List<Quest> _quests = [];
  
  int _playerPoints = 0;
  final List<int> _completedQuests = [];
  
  final ProgressService _progressService = ProgressService();

  bool _isInitialized = false;
  bool _isInitializing = false;

  Future<void> _initializeData() async {
    if (_isInitialized || _isInitializing) {
      print('WebDatabaseService already initialized or initializing, skipping...');
      return;
    }
    
    _isInitializing = true;
    print('🔄 Initializing web database...');
    
    // Загружаем сохраненный прогресс
    _playerPoints = await _progressService.getPlayerPoints();
    final savedQuests = await _progressService.getCompletedQuests();
    _completedQuests.addAll(savedQuests);
    
    print('📥 Loaded progress: $_playerPoints points, ${_completedQuests.length} completed quests');

    // ИНИЦИАЛИЗИРУЕМ ДАННЫЕ ТОЛЬКО ЕСЛИ ОНИ ПУСТЫЕ
    if (_substances.isEmpty) {
      _substances.addAll([
        Substance(substanceId: 1, name: 'Водород', formula: 'H2', molarMass: 2.02, description: 'Легкий горючий газ'),
        Substance(substanceId: 2, name: 'Кислород', formula: 'O2', molarMass: 32.00, description: 'Газ необходимый для дыхания'),
        Substance(substanceId: 3, name: 'Вода', formula: 'H2O', molarMass: 18.02, description: 'Оксид водорода'),
        Substance(substanceId: 4, name: 'Углерод', formula: 'C', molarMass: 12.01, description: 'Основной элемент органической химии'),
        Substance(substanceId: 5, name: 'Диоксид углерода', formula: 'CO2', molarMass: 44.01, description: 'Углекислый газ'),
        Substance(substanceId: 6, name: 'Метан', formula: 'CH4', molarMass: 16.04, description: 'Основной компонент природного газа'),
      ]);
      print('🧪 Added ${_substances.length} substances');
    }

    if (_reactions.isEmpty) {
      _reactions.addAll([
        ChemicalReaction(reactionId: 1, reactionString: '2H₂ + O₂ → 2H₂O', reactants: 'H2:2,O2:1', products: 'H2O:2', balancedCoefficients: '2,1,2'),
        ChemicalReaction(reactionId: 2, reactionString: 'C + O₂ → CO₂', reactants: 'C:1,O2:1', products: 'CO2:1', balancedCoefficients: '1,1,1'),
        ChemicalReaction(reactionId: 3, reactionString: 'CH₄ + 2O₂ → CO₂ + 2H₂O', reactants: 'CH4:1,O2:2', products: 'CO2:1,H2O:2', balancedCoefficients: '1,2,1,2'),
      ]);
      print('⚗️ Added ${_reactions.length} reactions');
    }

    if (_quests.isEmpty) {
      _quests.addAll([
        Quest(questId: 1, title: 'СИНТЕЗ ВОДЫ', description: 'Получите 36.04 г воды из водорода и кислорода', targetSubstanceId: 3, targetAmount: 36.04, availableReagents: '1,2', rewardPoints: 100),
        Quest(questId: 2, title: 'ПОЛУЧЕНИЕ CO₂', description: 'Получите 44.01 г диоксида углерода из углерода и кислорода', targetSubstanceId: 5, targetAmount: 44.01, availableReagents: '4,2', rewardPoints: 150),
        Quest(questId: 3, title: 'СЖИГАНИЕ МЕТАНА', description: 'Проведите реакцию горения метана с получением CO₂ и воды', targetSubstanceId: 5, targetAmount: 88.02, availableReagents: '6,2', rewardPoints: 200),
        Quest(questId: 4, title: 'РЕАКЦИЯ НЕЙТРАЛИЗАЦИИ', description: 'Проведите реакцию нейтрализации', targetSubstanceId: 3, targetAmount: 50.0, availableReagents: '1,2', rewardPoints: 250),
        Quest(questId: 5, title: 'ЭЛЕКТРОЛИЗ ВОДЫ', description: 'Проведите электролиз воды', targetSubstanceId: 3, targetAmount: 60.0, availableReagents: '3', rewardPoints: 300),
      ]);
      print('🎯 Added ${_quests.length} quests');
    }

    _isInitialized = true;
    _isInitializing = false;
    
    print('✅ Web database initialized:');
    print('   - Substances: ${_substances.length}');
    print('   - Reactions: ${_reactions.length}');
    print('   - Quests: ${_quests.length}');
    print('   - Player points: $_playerPoints');
    print('   - Completed quests: ${_completedQuests.length}');
  }

  // Геттеры - ОБЕСПЕЧИВАЕМ ЕДИНОКРАТНУЮ ИНИЦИАЛИЗАЦИЮ
  Future<List<Substance>> getAllSubstances() async {
    if (!_isInitialized) await _initializeData();
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_substances);
  }

  Future<List<Quest>> getAllQuests() async {
    if (!_isInitialized) await _initializeData();
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_quests);
  }

  Future<List<ChemicalReaction>> getAllReactions() async {
    if (!_isInitialized) await _initializeData();
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_reactions);
  }

  Future<Map<String, dynamic>> loadPlayerProgress(int playerId) async {
    if (!_isInitialized) await _initializeData();
    await Future.delayed(const Duration(milliseconds: 50));
    return {
      'points': _playerPoints,
      'completedQuests': _completedQuests.join(','),
    };
  }

  Future<void> resetPlayerProgress(int playerId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _playerPoints = 0;
    _completedQuests.clear();
    
    // Сбрасываем в постоянном хранилище
    await _progressService.resetProgress();
    
    print('🔄 Progress reset in web database');
  }

  void completeQuest(int questId) {
    if (!_completedQuests.contains(questId)) {
      _completedQuests.add(questId);
      final quest = _quests.firstWhere((q) => q.questId == questId);
      _playerPoints += quest.rewardPoints;
      
      // Сохраняем прогресс асинхронно
      _saveProgressAsync();
      
      print('🎉 Quest $questId completed. Total points: $_playerPoints');
    }
  }

  Future<void> _saveProgressAsync() async {
    await _progressService.savePlayerPoints(_playerPoints);
    await _progressService.saveCompletedQuests(_completedQuests);
  }

  List<Quest> getAvailableQuests() {
    return _quests.where((q) => !_completedQuests.contains(q.questId)).toList();
  }

  // Новые методы для получения данных о прогрессе
  int get playerPoints => _playerPoints;
  List<int> get completedQuests => List.from(_completedQuests);
  bool get isInitialized => _isInitialized;

  // Метод для полного сброса
  Future<void> hardReset() async {
    _isInitialized = false;
    _isInitializing = false;
    _substances.clear();
    _reactions.clear();
    _quests.clear();
    _playerPoints = 0;
    _completedQuests.clear();
    
    await _progressService.resetProgress();
    print('💥 Hard reset complete - all data cleared');
  }
}