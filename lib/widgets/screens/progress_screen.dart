import 'package:flutter/material.dart';
import '../../services/game_manager.dart';
import '../../utils/color_palette.dart';

class ProgressScreen extends StatelessWidget {
  final GameManager gameManager;

  const ProgressScreen({super.key, required this.gameManager});

  @override
  Widget build(BuildContext context) {
    final completedQuests = gameManager.completedQuests.length;
    final totalQuests = gameManager.allQuests.length;
    final progressPercentage = totalQuests > 0 ? (completedQuests / totalQuests * 100) : 0;
    final achievedCount = _calculateAchievedCount(gameManager);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой прогресс'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Статистика
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Общая статистика',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          '${gameManager.playerPoints}', 
                          'Всего очков', 
                          Icons.emoji_events
                        ),
                        _buildStatItem(
                          '$completedQuests', 
                          'Выполнено заданий', 
                          Icons.assignment_turned_in
                        ),
                        _buildStatItem(
                          '$achievedCount', 
                          'Достижения', 
                          Icons.workspace_premium
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Прогресс-бар
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Общий прогресс',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progressPercentage / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${progressPercentage.toStringAsFixed(1)}% выполнено ($completedQuests/$totalQuests заданий)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Прогресс по заданиям
            const Text(
              'Прогресс по заданиям',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: gameManager.allQuests.map((quest) {
                  final isCompleted = gameManager.completedQuests.contains(quest.questId);
                  return _buildProgressItem(
                    quest.title,
                    quest.rewardPoints,
                    isCompleted,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildProgressItem(String title, int points, bool completed) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: completed ? AppColors.success : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check : Icons.schedule,
            color: completed ? Colors.white : Colors.grey,
          ),
        ),
        title: Text(title),
        subtitle: Text('$points очков'),
        trailing: Chip(
          label: Text(completed ? 'Выполнено' : 'В процессе'),
          backgroundColor: completed ? AppColors.success.withOpacity(0.2) : null,
        ),
      ),
    );
  }

  int _calculateAchievedCount(GameManager gameManager) {
    final achievements = {
      'first_reaction': gameManager.completedQuests.isNotEmpty,
      'water_master': gameManager.completedQuests.contains(1),
      'co2_expert': gameManager.completedQuests.contains(2),
      'methane_pro': gameManager.completedQuests.contains(3),
      'chemistry_genius': gameManager.completedQuests.length >= 3,
    };
    
    return achievements.values.where((achieved) => achieved).length;
  }
}