import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_goal.dart';

abstract class SavingsRepository {
  Future<List<SavingsGoal>> loadGoals();
  Future<void> saveGoals(List<SavingsGoal> goals);
}

class SharedPrefsSavingsRepository implements SavingsRepository {
  static const String storageKey = 'mysimpanan_savings_goals';

  const SharedPrefsSavingsRepository();

  @override
  Future<List<SavingsGoal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(storageKey);
    if (rawJson == null || rawJson.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List) {
        return decoded
            .map((item) => SavingsGoal.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveGoals(List<SavingsGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(goals.map((g) => g.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }
}
