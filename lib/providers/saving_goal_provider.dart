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

  // ----- Read helpers -----
  SavingGoalModel? getGoal(int key) {
    return _box.get(key);
  }

  // ----- Add / Update / Delete -----
  Future<void> add(SavingGoalModel g) async {
    await _box.add(g);
    notifyListeners();
  }

  // alias used by some UI files: addGoal
  Future<void> addGoal(SavingGoalModel g) => add(g);

  Future<void> updateGoal(int key, SavingGoalModel updated) async {
    await _box.put(key, updated);
    notifyListeners();
  }

  // alias used by some UI files: editGoal
  Future<void> editGoal(int key, SavingGoalModel updated) =>
      updateGoal(key, updated);

  Future<void> deleteGoal(int key) async {
    await _box.delete(key);
    notifyListeners();
  }

  // ----- Business: add saved amount -----
  Future<void> addSaving(int key, double amount) async {
    final g = _box.get(key);
    if (g == null) return;

    g.saved += amount;
    await g.save();
    notifyListeners();
  }

  // DELETE ALL
  Future<void> clearAllGoals() async {
    await _box.clear();
    notifyListeners();
 }
}
