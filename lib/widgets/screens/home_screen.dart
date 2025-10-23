import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'quest_selection_screen.dart';
import 'progress_screen.dart';
import 'achievements_screen.dart';
import '../../services/game_manager.dart';
import '../../services/web_database_service.dart';
import '../../models/quest.dart';
import '../../models/substance.dart';
import '../common/lab_assistant_widget.dart';
import '../../models/lab_assistant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GameManager _gameManager = GameManager();
  final WebDatabaseService _dbService = WebDatabaseService();
  final LabAssistant _assistant = LabAssistant(
    name: 'Дмитрий',
    imagePath: 'assets/images/lab_assistant.png',
    phrases: [
      'Добро пожаловать в химическую лабораторию!',
      'Готовы провести несколько экспериментов?',
      'Не забудьте надеть защитные очки!',
      'Химия - это весело и интересно!',
      'Сегодня отличный день для экспериментов!',
      'Помните о технике безопасности!',
    ],
  );

  bool _isLoading = true;
  String _loadingStatus = 'Загружаем лабораторию...';

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      print('🎮 Starting game initialization...');
      setState(() {
        _loadingStatus = 'Загружаем вещества...';
      });
      
      await _gameManager.initializeGameData();
      
      setState(() {
        _loadingStatus = 'Проверяем прогресс...';
      });
      
      _gameManager.printDebugInfo();
      
      print('✅ Game initialization complete');
      
    } catch (e) {
      print('❌ Error initializing game: $e');
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка загрузки'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Не удалось загрузить данные игры.'),
            const SizedBox(height: 10),
            Text('Ошибка: $error', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _retryInitialization();
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  void _retryInitialization() {
    setState(() {
      _isLoading = true;
      _loadingStatus = 'Повторная загрузка...';
    });
    _initializeGame();
  }

  void _navigateToQuestSelection() {
    if (!_gameManager.isInitialized) {
      _showNotInitializedDialog();
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestSelectionScreen(
          gameManager: _gameManager,
          onQuestCompleted: _onQuestCompleted,
        ),
      ),
    );
  }

  void _onQuestCompleted() {
    setState(() {});
    print('🔄 HomeScreen: Quest completed, refreshing state...');
  }

  void _navigateToProgress() {
    if (!_gameManager.isInitialized) {
      _showNotInitializedDialog();
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressScreen(gameManager: _gameManager),
      ),
    );
  }

  void _navigateToAchievements() {
    if (!_gameManager.isInitialized) {
      _showNotInitializedDialog();
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchievementsScreen(gameManager: _gameManager),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _showNotInitializedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Данные не загружены'),
        content: const Text('Пожалуйста, подождите завершения загрузки игровых данных.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDebugInfo() {
    _gameManager.printDebugInfo();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Отладочная информация:'),
            Text('Очки: ${_gameManager.playerPoints}'),
            Text('Задания: ${_gameManager.availableQuests.length} доступно'),
            Text('Выполнено: ${_gameManager.completedQuests.length}'),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                _loadingStatus,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${_gameManager.allQuests.length} заданий',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ВЫЧИСЛЯЕМ ДАННЫЕ
    final progressPercentage = _calculateProgressPercentage();
    final achievedCount = _calculateAchievedCount();
    final allQuestsCompleted = _checkAllQuestsCompleted();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Химический симулятор'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_gameManager.playerPoints}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: _navigateToProgress,
            tooltip: 'Прогресс',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _showDebugInfo,
            tooltip: 'Отладка',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Лаборант (компактный)
              SizedBox(
                height: 80,
                child: LabAssistantWidget(assistant: _assistant),
              ),
              
              const SizedBox(height: 16), // Увеличили отступ после лаборанта
              
              // Основные кнопки (2x2 сетка) - КОМПАКТНЫЕ
              _buildCompactMenuGrid(),
              
              const SizedBox(height: 8),
              
              // Информация о версии (компактная)
              _buildVersionInfo(allQuestsCompleted),
            ],
          ),
        ),
      ),
    );
  }

  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДЛЯ ВЫЧИСЛЕНИЙ
  double _calculateProgressPercentage() {
    if (_gameManager.allQuests.isEmpty) return 0.0;
    return (_gameManager.completedQuests.length / _gameManager.allQuests.length) * 100;
  }

  int _calculateAchievedCount() {
    final achievements = {
      'first_reaction': _gameManager.completedQuests.isNotEmpty,
      'water_master': _gameManager.completedQuests.contains(1),
      'co2_expert': _gameManager.completedQuests.contains(2),
      'methane_pro': _gameManager.completedQuests.contains(3),
      'chemistry_genius': _gameManager.completedQuests.length >= 3,
    };
    
    return achievements.values.where((achieved) => achieved).length;
  }

  bool _checkAllQuestsCompleted() {
    return _gameManager.completedQuests.length == _gameManager.allQuests.length;
  }

  Widget _buildCompactMenuGrid() {
    final progressPercentage = _calculateProgressPercentage();
    final achievedCount = _calculateAchievedCount();

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _buildCompactMenuCard(
          icon: Icons.science,
          title: 'Эксперименты',
          subtitle: '${_gameManager.availableQuests.length} доступно',
          color: Colors.blue,
          onTap: _navigateToQuestSelection,
          badge: _gameManager.availableQuests.length > 0 ? '${_gameManager.availableQuests.length}' : null,
        ),
        _buildCompactMenuCard(
          icon: Icons.emoji_events,
          title: 'Достижения',
          subtitle: '$achievedCount получено',
          color: Colors.amber,
          onTap: _navigateToAchievements,
          badge: achievedCount > 0 ? '$achievedCount' : null,
        ),
        _buildCompactMenuCard(
          icon: Icons.leaderboard,
          title: 'Прогресс',
          subtitle: '${progressPercentage.toStringAsFixed(0)}%',
          color: Colors.green,
          onTap: _navigateToProgress,
        ),
        _buildCompactMenuCard(
          icon: Icons.settings,
          title: 'Настройки',
          subtitle: 'Звук, тема',
          color: Colors.grey,
          onTap: _navigateToSettings,
        ),
      ],
    );
  }

  Widget _buildCompactMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Иконка
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Заголовок
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 2),
                  
                  // Подзаголовок
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              
              // Бейдж (если есть)
              if (badge != null)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 7,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo(bool allQuestsCompleted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Химическая лаборатория v1.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 9,
            ),
          ),
          if (allQuestsCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ВСЕ ВЫПОЛНЕНО!',
                style: TextStyle(
                  fontSize: 7,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}