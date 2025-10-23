import 'package:flutter/material.dart';
import '../../services/game_manager.dart';
import '../../utils/color_palette.dart';

class AchievementsScreen extends StatelessWidget {
  final GameManager gameManager;

  const AchievementsScreen({super.key, required this.gameManager});

  @override
  Widget build(BuildContext context) {
    final achievements = _getAchievements(gameManager);
    final achievedCount = achievements.values.where((achieved) => achieved).length;
    final totalAchievements = achievements.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
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
            // Прогресс достижений
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, size: 40, color: AppColors.secondary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Соберите все достижения!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: achievedCount / totalAchievements,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          ),
                          const SizedBox(height: 4),
                          Text('$achievedCount из $totalAchievements достижений получено'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Список достижений
            Expanded(
              child: ListView(
                children: [
                  _buildAchievementItem(
                    'Первый эксперимент',
                    'Проведите свою первую химическую реакцию',
                    Icons.science,
                    achievements['first_reaction'] ?? false,
                    50,
                  ),
                  _buildAchievementItem(
                    'Мастер синтеза',
                    'Выполните все задания по синтезу',
                    Icons.water_drop,
                    achievements['water_master'] ?? false,
                    100,
                  ),
                  _buildAchievementItem(
                    'Исследователь',
                    'Откройте все доступные реакции',
                    Icons.explore,
                    achievements['co2_expert'] ?? false,
                    150,
                  ),
                  _buildAchievementItem(
                    'Профессор химии',
                    'Наберите 1000 очков',
                    Icons.school,
                    achievements['methane_pro'] ?? false,
                    200,
                  ),
                  _buildAchievementItem(
                    'Нобелевская премия',
                    'Завершите все эксперименты',
                    Icons.emoji_events,
                    achievements['chemistry_genius'] ?? false,
                    500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(
    String title,
    String description,
    IconData icon,
    bool unlocked,
    int points,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: unlocked ? null : Colors.grey.shade100,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: unlocked ? AppColors.secondary : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: unlocked ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                color: unlocked ? Colors.grey : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text(
                  '$points очков',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: unlocked
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }

  Map<String, bool> _getAchievements(GameManager gameManager) {
    return {
      'first_reaction': gameManager.completedQuests.isNotEmpty,
      'water_master': gameManager.completedQuests.contains(1),
      'co2_expert': gameManager.completedQuests.contains(2),
      'methane_pro': gameManager.completedQuests.contains(3),
      'chemistry_genius': gameManager.completedQuests.length >= 3,
    };
  }
}