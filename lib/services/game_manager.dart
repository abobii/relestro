import '../models/quest.dart';
import '../models/substance.dart';
import '../services/web_database_service.dart';

class GameManager {
  int _playerPoints = 0;
  final List<int> _completedQuests = [];
  final List<Quest> _allQuests = [];
  final List<Substance> _allSubstances = [];
  
  final WebDatabaseService _dbService = WebDatabaseService();
  
  bool _isInitialized = false;
  bool _isInitializing = false;

  int get playerPoints => _playerPoints;
  List<int> get completedQuests => List.from(_completedQuests);
  List<Quest> get availableQuests => _allQuests.where((q) => !_completedQuests.contains(q.questId)).toList();
  List<Quest> get allQuests => List.from(_allQuests);
  bool get isInitialized => _isInitialized;

  Future<void> initializeGameData() async {
    if (_isInitialized || _isInitializing) {
      print('🚫 GameManager already initialized, skipping...');
      return;
    }
    
    _isInitializing = true;
    print('🔄 GameManager initializing...');
    
    try {
      // ОЧИЩАЕМ ВСЕ ДАННЫЕ ПЕРЕД ЗАГРУЗКОЙ
      _allQuests.clear();
      _allSubstances.clear();
      _completedQuests.clear();
      _playerPoints = 0;
      
      // ЗАГРУЖАЕМ ДАННЫЕ ИЗ БАЗЫ
      final substances = await _dbService.getAllSubstances();
      final quests = await _dbService.getAllQuests();
      final progress = await _dbService.loadPlayerProgress(0);
      
      // ДОБАВЛЯЕМ ДАННЫЕ
      _allSubstances.addAll(substances);
      _allQuests.addAll(quests);
      _playerPoints = progress['points'] ?? 0;
      
      final completedString = progress['completedQuests']?.toString() ?? '';
      if (completedString.isNotEmpty) {
        _completedQuests.addAll(completedString.split(',').map((id) => int.parse(id)));
      }
      
      print('✅ GameManager initialized:');
      print('   - Substances: ${_allSubstances.length}');
      print('   - Quests: ${_allQuests.length}');
      print('   - Points: $_playerPoints');
      print('   - Completed quests: ${_completedQuests.length}');
      print('   - Available quests: ${availableQuests.length}');
      
      // ВАЛИДАЦИЯ ДАННЫХ
      _validateData();
      
    } catch (e) {
      print('❌ Error initializing GameManager: $e');
      _playerPoints = 0;
      _completedQuests.clear();
    } finally {
      _isInitialized = true;
      _isInitializing = false;
    }
  }

  void _validateData() {
    print('🔍 Validating data...');
    
    // Проверяем дубликаты заданий
    final questIds = _allQuests.map((q) => q.questId).toList();
    final uniqueQuestIds = questIds.toSet();
    
    if (questIds.length != uniqueQuestIds.length) {
      print('❌ DUPLICATE QUESTS FOUND!');
      print('   - Total quests: ${questIds.length}');
      print('   - Unique quests: ${uniqueQuestIds.length}');
      print('   - Quest IDs: $questIds');
    } else {
      print('✅ No duplicate quests found');
    }
    
    // Проверяем корректность completedQuests
    final invalidCompleted = _completedQuests.where((id) => !_allQuests.any((q) => q.questId == id)).toList();
    if (invalidCompleted.isNotEmpty) {
      print('❌ Invalid completed quests: $invalidCompleted');
    } else {
      print('✅ Completed quests validation passed');
    }
  }

  void completeQuest(int questId) {
    if (!_completedQuests.contains(questId)) {
      _completedQuests.add(questId);
      final quest = _allQuests.firstWhere((q) => q.questId == questId);
      _playerPoints += quest.rewardPoints;
      
      _dbService.completeQuest(questId);
      
      print('🎉 Quest $questId completed! +${quest.rewardPoints} points');
    }
  }

  Future<void> resetProgress() async {
    print('🔄 Resetting progress...');
    
    _playerPoints = 0;
    _completedQuests.clear();
    
    await _dbService.resetPlayerProgress(0);
    
    print('✅ Progress reset complete');
  }

  Future<void> hardReset() async {
    print('💥 Performing hard reset...');
    
    _isInitialized = false;
    _isInitializing = false;
    _playerPoints = 0;
    _completedQuests.clear();
    _allQuests.clear();
    _allSubstances.clear();
    
    await _dbService.hardReset();
    
    print('✅ Hard reset complete');
  }

  Substance? getSubstanceById(int id) {
    try {
      return _allSubstances.firstWhere((s) => s.substanceId == id);
    } catch (e) {
      return null;
    }
  }

  Quest? getQuestById(int id) {
    try {
      return _allQuests.firstWhere((q) => q.questId == id);
    } catch (e) {
      return null;
    }
  }

  bool isQuestCompleted(int questId) {
    return _completedQuests.contains(questId);
  }

  double getProgressPercentage() {
    if (_allQuests.isEmpty) return 0.0;
    return (_completedQuests.length / _allQuests.length) * 100;
  }

  void printDebugInfo() {
    print('\n=== 🧪 GAME MANAGER DEBUG INFO ===');
    print('Initialized: $_isInitialized');
    print('Player Points: $_playerPoints');
    print('Completed Quests: ${_completedQuests.length}');
    print('All Quests: ${_allQuests.length}');
    print('Available Quests: ${availableQuests.length}');
    print('Quest IDs: ${_allQuests.map((q) => q.questId).toList()}');
    print('Completed IDs: $_completedQuests');
    print('Progress: ${getProgressPercentage().toStringAsFixed(1)}%');
    
    for (final quest in _allQuests) {
      final status = _completedQuests.contains(quest.questId) ? '✅' : '⏳';
      print('   $status ${quest.title} (ID: ${quest.questId})');
    }
    print('================================\n');
  }
}