import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/saving_goal_model.dart';

class SavingGoalProvider extends ChangeNotifier {
  static const boxName = "saving_goals_box";

  late Box<SavingGoalModel> _box;

  List<SavingGoalModel> get goals => _box.values.toList();

  Future<void> init() async {
    _box = await Hive.openBox<SavingGoalModel>(boxName);
    notifyListeners();
  }

  // ADD GOAL
  Future<void> add(SavingGoalModel g) async {
    await _box.add(g);
    notifyListeners();
  }

  // UPDATE GOAL
  Future<void> updateGoal(int key, SavingGoalModel updated) async {
    await _box.put(key, updated);
    notifyListeners();
  }

  // DELETE GOAL
  Future<void> deleteGoal(int key) async {
    await _box.delete(key);
    notifyListeners();
  }

  // ADD SAVED AMOUNT
  Future<void> addSaving(int key, double amount) async {
    final g = _box.get(key);
    if (g == null) return;

    g.saved += amount;
    await g.save();
    notifyListeners();
  }
}
