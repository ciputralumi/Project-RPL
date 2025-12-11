import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/goal_model.dart';

class GoalProvider extends ChangeNotifier {
  final Box<GoalModel> _box = Hive.box<GoalModel>('goals');

  List<GoalModel> get goals => _box.values.toList();

  void addGoal(GoalModel goal) {
    _box.add(goal);
    notifyListeners();
  }

  void updateGoal(int key, GoalModel updated) {
    _box.put(key, updated);
    notifyListeners();
  }

  void deleteGoal(int key) {
    _box.delete(key);
    notifyListeners();
  }

  void addProgress(int key, double amount) {
    final g = _box.get(key);
    if (g == null) return;

    g.currentAmount += amount;
    g.save();
    notifyListeners();
  }
}
