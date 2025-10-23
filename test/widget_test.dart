import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chemistry_simulator/models/lab_assistant.dart';
import 'package:chemistry_simulator/models/flask.dart';
import 'package:chemistry_simulator/models/quest.dart';
import 'package:chemistry_simulator/widgets/common/lab_assistant_widget.dart';
import 'package:chemistry_simulator/widgets/common/flask_widget.dart';
import 'package:chemistry_simulator/widgets/common/animated_button.dart';

void main() {
  group('LabAssistantWidget Tests', () {
    testWidgets('should display assistant name and initial phrase', (WidgetTester tester) async {
      // Arrange
      final assistant = LabAssistant(
        name: 'Тестовый ассистент',
        imagePath: 'assets/images/lab_assistant.png',
        phrases: ['Первая фраза', 'Вторая фраза'],
      );

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LabAssistantWidget(assistant: assistant),
        ),
      ));

      // Assert
      expect(find.text('Тестовый ассистент'), findsOneWidget);
      expect(find.text('Первая фраза'), findsOneWidget);
    });

    testWidgets('should change phrase when tapped', (WidgetTester tester) async {
      // Arrange
      final assistant = LabAssistant(
        name: 'Тест',
        imagePath: 'test.png',
        phrases: ['Фраза 1', 'Фраза 2'],
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LabAssistantWidget(assistant: assistant),
        ),
      ));

      // Act - tap the widget
      await tester.tap(find.byType(LabAssistantWidget));
      await tester.pump();

      // Assert - should show second phrase
      expect(find.text('Фраза 2'), findsOneWidget);
    });
  });

  group('FlaskWidget Tests', () {
    testWidgets('should display flask with liquid', (WidgetTester tester) async {
      // Arrange
      final flask = Flask(
        id: '1',
        imagePath: '',
        color: Colors.blue,
        maxVolume: 100,
        currentVolume: 50,
        substanceFormula: 'H2O',
      );

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FlaskWidget(flask: flask),
        ),
      ));

      // Assert
      expect(find.byType(FlaskWidget), findsOneWidget);
    });

    testWidgets('should handle tap when onTap provided', (WidgetTester tester) async {
      // Arrange
      var tapped = false;
      final flask = Flask(
        id: '1',
        imagePath: '',
        color: Colors.red,
        maxVolume: 100,
        currentVolume: 75,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FlaskWidget(
            flask: flask,
            onTap: () => tapped = true,
          ),
        ),
      ));

      // Act
      await tester.tap(find.byType(FlaskWidget));
      await tester.pump();

      // Assert
      expect(tapped, true);
    });
  });

  group('AnimatedButton Tests', () {
    testWidgets('should be tappable when enabled', (WidgetTester tester) async {
      // Arrange
      var tapped = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            onPressed: () => tapped = true,
            child: const Text('Test Button'),
          ),
        ),
      ));

      // Act
      await tester.tap(find.byType(AnimatedButton));
      await tester.pump();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should display child widget', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            onPressed: () {},
            child: const Text('Click Me'),
          ),
        ),
      ));

      // Assert
      expect(find.text('Click Me'), findsOneWidget);
    });
  });

  group('Quest Model Widget Compatibility', () {
    test('Quest should work with widget requirements', () {
      // This test ensures that Quest model has all properties needed by widgets
      final quest = Quest(
        questId: 1,
        title: 'Тестовый квест',
        description: 'Описание тестового квеста',
        targetSubstanceId: 1,
        targetAmount: 50.0,
        availableReagents: '1,2,3',
        rewardPoints: 100,
      );

      expect(quest.title, isNotEmpty);
      expect(quest.description, isNotEmpty);
      expect(quest.targetAmount, greaterThan(0));
      expect(quest.rewardPoints, greaterThan(0));
      expect(quest.getAvailableReagentIds(), isList);
    });
  });
}