import 'package:flutter_test/flutter_test.dart';
import 'package:chemistry_simulator/models/quest.dart';
import 'package:chemistry_simulator/models/lab_assistant.dart';

void main() {
  group('LabAssistant Tests', () {
    test('should create assistant', () {
      final assistant = LabAssistant(
        name: 'Test',
        imagePath: 'test.png',
        phrases: ['Hello'],
      );
      expect(assistant.name, 'Test');
    });
  });

  group('Quest Tests', () {
    test('should create quest', () {
      final quest = Quest(
        questId: 1,
        title: 'Test Quest',
        description: 'Test',
        targetSubstanceId: 1,
        targetAmount: 10.0,
        availableReagents: '1,2',
        rewardPoints: 100,
      );
      expect(quest.questId, 1);
    });
  });
}