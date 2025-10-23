import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _pointsKey = 'player_points';
  static const String _completedQuestsKey = 'completed_quests';

  Future<int> getPlayerPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_pointsKey) ?? 0;
    } catch (e) {
      print('Error getting player points: $e');
      return 0;
    }
  }

  Future<List<int>> getCompletedQuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedString = prefs.getString(_completedQuestsKey) ?? '';
      if (completedString.isEmpty) return [];
      
      return completedString.split(',').map((id) {
        return int.tryParse(id) ?? -1;
      }).where((id) => id != -1).toList();
    } catch (e) {
      print('Error getting completed quests: $e');
      return [];
    }
  }

  Future<void> savePlayerPoints(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_pointsKey, points);
      print('Player points saved: $points');
    } catch (e) {
      print('Error saving player points: $e');
    }
  }

  Future<void> saveCompletedQuests(List<int> questIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedString = questIds.join(',');
      await prefs.setString(_completedQuestsKey, completedString);
      print('Completed quests saved: $completedString');
    } catch (e) {
      print('Error saving completed quests: $e');
    }
  }

  Future<void> resetProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pointsKey);
      await prefs.remove(_completedQuestsKey);
      print('Progress reset in storage');
    } catch (e) {
      print('Error resetting progress: $e');
    }
  }

  // Дополнительные методы для отладки
  Future<void> printStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final points = prefs.getInt(_pointsKey) ?? 0;
      final quests = prefs.getString(_completedQuestsKey) ?? '';
      print('Stored data - Points: $points, Quests: $quests');
    } catch (e) {
      print('Error reading stored data: $e');
    }
  }
}