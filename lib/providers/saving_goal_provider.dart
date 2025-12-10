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

  // -------------------------------
  // ADD GOAL
  // -------------------------------
  Future<void> addGoal(SavingGoalModel g) async {
    await _box.add(g);
    notifyListeners();
  }

  // -------------------------------
  // EDIT GOAL
  // -------------------------------
  Future<void> editGoal(int key, SavingGoalModel g) async {
    await _box.put(key, g);
    notifyListeners();
  }

  // -------------------------------
  // DELETE GOAL
  // -------------------------------
  Future<void> deleteGoal(int key) async {
    await _box.delete(key);
    notifyListeners();
  }

  // -------------------------------
  // ADD SAVING AMOUNT
  // -------------------------------
  Future<void> addSaving(int key, double amount) async {
    final goal = _box.get(key);

    if (goal == null) return;

    goal.saved += amount;
    await goal.save();

    notifyListeners();
  }
}
