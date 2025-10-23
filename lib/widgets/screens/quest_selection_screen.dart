import 'package:flutter/material.dart';
import '../../models/quest.dart';
import '../../services/game_manager.dart';
import '../../utils/color_palette.dart';
import '../common/animated_button.dart';
import 'lab_screen.dart';

class QuestSelectionScreen extends StatefulWidget {
  final GameManager gameManager;
  final VoidCallback onQuestCompleted;

  const QuestSelectionScreen({
    super.key,
    required this.gameManager,
    required this.onQuestCompleted,
  });

  @override
  State<QuestSelectionScreen> createState() => _QuestSelectionScreenState();
}

class _QuestSelectionScreenState extends State<QuestSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final availableQuests = widget.gameManager.availableQuests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите эксперимент'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статистика
            _buildStatsCard(),
            
            const SizedBox(height: 20),
            
            // Заголовок
            const Text(
              'Доступные эксперименты:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Список заданий
            Expanded(
              child: availableQuests.isEmpty
                  ? _buildNoQuestsScreen()
                  : ListView.builder(
                      itemCount: availableQuests.length,
                      itemBuilder: (context, index) {
                        final quest = availableQuests[index];
                        return _buildQuestCard(quest);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.secondary, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.gameManager.playerPoints} очков',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.gameManager.availableQuests.length} заданий доступно',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoQuestsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_turned_in, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            'Все эксперименты завершены!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Вы отлично поработали в лаборатории.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AnimatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Вернуться в меню'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(Quest quest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и награда
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quest.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '${quest.rewardPoints}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Описание
            Text(
              quest.description,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),

            const SizedBox(height: 12),

            // Цель
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Цель: ${quest.targetAmount} г',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Кнопка начала
            AnimatedButton(
              onPressed: () => _startQuest(quest),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Начать эксперимент',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuest(Quest quest) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LabScreen(
          quest: quest,
          gameManager: widget.gameManager,
          onQuestCompleted: widget.onQuestCompleted,
        ),
      ),
    );
  }
}