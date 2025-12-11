import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/saving_goal_model.dart';

class SavingGoalProvider extends ChangeNotifier {
  static const boxName = "saving_goals_box";

  late Box<SavingGoalModel> _box;

  // Tambahkan variabel goals yang bisa diubah
  List<SavingGoalModel> _goals = [];
  List<SavingGoalModel> get goals => _goals;

  Future<void> init() async {
    _box = await Hive.openBox<SavingGoalModel>(boxName);
    _goals = _box.values.toList();
    notifyListeners();
  }

  // ----- Read helpers -----
  SavingGoalModel? getGoal(int key) {
    return _box.get(key);
  }

  // ----- Add / Update / Delete -----
  Future<void> add(SavingGoalModel g) async {
    await _box.add(g);
    _goals = _box.values.toList();
    notifyListeners();
  }

  Future<void> addGoal(SavingGoalModel g) => add(g);

  Future<void> updateGoal(int key, SavingGoalModel updated) async {
    await _box.put(key, updated);
    _goals = _box.values.toList();
    notifyListeners();
  }

  Future<void> editGoal(int key, SavingGoalModel updated) =>
      updateGoal(key, updated);

  Future<void> deleteGoal(int key) async {
    await _box.delete(key);
    _goals = _box.values.toList();
    notifyListeners();
  }

  // ----- Business: add saved amount -----
  Future<void> addSaving(int key, double amount) async {
    final g = _box.get(key);
    if (g == null) return;

    g.saved += amount;
    await g.save();

    _goals = _box.values.toList();
    notifyListeners();
  }

  // DELETE ALL
  Future<void> clearAllGoals() async {
    await _box.clear();
    _goals = [];
    notifyListeners();
  }

  // RESET (Called from Settings Page)
  void reloadGoals() {
    _goals = _box.values.toList();
    notifyListeners();
  }
}
