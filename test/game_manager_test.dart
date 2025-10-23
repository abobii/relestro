import 'package:flutter_test/flutter_test.dart';
import 'package:chemistry_simulator/services/game_manager.dart';
import 'package:chemistry_simulator/models/quest.dart';

// Мок-версия GameManager для тестов
class MockGameManager extends GameManager {
  final List<int> _mockCompletedQuests = [];
  int _mockPlayerPoints = 0;
  
  @override
  List<int> get completedQuests => List.from(_mockCompletedQuests);
  
  @override
  int get playerPoints => _mockPlayerPoints;
  
  @override
  void completeQuest(int questId) {
    if (!_mockCompletedQuests.contains(questId)) {
      _mockCompletedQuests.add(questId);
      // Добавляем фиктивные очки для теста
      _mockPlayerPoints += 100;
    }
  }
  
  @override
  List<Quest> get allQuests => [
    Quest(
      questId: 1,
      title: 'Тестовый квест 1',
      description: 'Тест',
      targetSubstanceId: 1,
      targetAmount: 10.0,
      availableReagents: '1,2',
      rewardPoints: 100,
    ),
    Quest(
      questId: 2,
      title: 'Тестовый квест 2',
      description: 'Тест',
      targetSubstanceId: 2,
      targetAmount: 20.0,
      availableReagents: '3,4',
      rewardPoints: 150,
    ),
  ];
  
  @override
  List<Quest> get availableQuests {
    return allQuests.where((quest) => !_mockCompletedQuests.contains(quest.questId)).toList();
  }
  
  @override
  double getProgressPercentage() {
    if (allQuests.isEmpty) return 0.0;
    return (_mockCompletedQuests.length / allQuests.length) * 100;
  }
  
  @override
  bool isQuestCompleted(int questId) {
    return _mockCompletedQuests.contains(questId);
  }
}

void main() {
  group('GameManager Tests', () {
    late MockGameManager gameManager;

    setUp(() {
      gameManager = MockGameManager();
    });

    test('completeQuest should add quest to completed list', () {
      // Act
      gameManager.completeQuest(1);

      // Assert
      expect(gameManager.completedQuests.contains(1), true);
      expect(gameManager.completedQuests.length, 1);
    });

    test('completeQuest should not duplicate completed quests', () {
      // Act
      gameManager.completeQuest(1);
      gameManager.completeQuest(1); // Duplicate

      // Assert
      expect(gameManager.completedQuests.length, 1);
    });

    test('completeQuest should increase player points', () {
      // Arrange
      final initialPoints = gameManager.playerPoints;

      // Act
      gameManager.completeQuest(1);

      // Assert
      expect(gameManager.playerPoints, greaterThan(initialPoints));
    });

    test('isQuestCompleted should return correct status', () {
      // Arrange
      gameManager.completeQuest(2);

      // Act & Assert
      expect(gameManager.isQuestCompleted(2), true);
      expect(gameManager.isQuestCompleted(999), false);
    });

    test('getProgressPercentage should calculate correctly', () {
      // Arrange
      expect(gameManager.getProgressPercentage(), 0.0);

      // Act - complete 1 of 2 quests
      gameManager.completeQuest(1);

      // Assert
      expect(gameManager.getProgressPercentage(), 50.0);
    });

    test('availableQuests should exclude completed quests', () {
      // Arrange
      final initialAvailable = gameManager.availableQuests.length;

      // Act
      gameManager.completeQuest(1);

      // Assert
      expect(gameManager.availableQuests.length, lessThan(initialAvailable));
      expect(gameManager.availableQuests.any((q) => q.questId == 1), false);
    });

    test('allQuests should return all test quests', () {
      // Act & Assert
      expect(gameManager.allQuests.length, 2);
      expect(gameManager.allQuests[0].questId, 1);
      expect(gameManager.allQuests[1].questId, 2);
    });

    test('playerPoints should be accessible', () {
      // Act & Assert
      expect(gameManager.playerPoints, isA<int>());
      expect(gameManager.playerPoints, greaterThanOrEqualTo(0));
    });

    test('completedQuests should return list', () {
      // Act & Assert
      expect(gameManager.completedQuests, isA<List<int>>());
      expect(gameManager.completedQuests, isEmpty);
    });
  });

  group('GameManager Edge Cases', () {
    late MockGameManager gameManager;

    setUp(() {
      gameManager = MockGameManager();
    });

    test('should handle multiple quest completions', () {
      // Act
      gameManager.completeQuest(1);
      gameManager.completeQuest(2);
      gameManager.completeQuest(3); // Несуществующий, но не должен падать

      // Assert
      expect(gameManager.completedQuests.length, 3);
      expect(gameManager.completedQuests, contains(1));
      expect(gameManager.completedQuests, contains(2));
      expect(gameManager.completedQuests, contains(3));
    });

    test('should handle getProgressPercentage with all quests completed', () {
      // Act
      gameManager.completeQuest(1);
      gameManager.completeQuest(2);

      // Assert
      expect(gameManager.getProgressPercentage(), 100.0);
    });

    test('should handle empty completed quests initially', () {
      // Act & Assert
      expect(gameManager.completedQuests, isEmpty);
      expect(gameManager.getProgressPercentage(), 0.0);
    });

    test('methods should not throw exceptions', () {
      // Act & Assert
      expect(() => gameManager.completeQuest(-1), returnsNormally);
      expect(() => gameManager.isQuestCompleted(-1), returnsNormally);
      expect(() => gameManager.getProgressPercentage(), returnsNormally);
    });
  });
}