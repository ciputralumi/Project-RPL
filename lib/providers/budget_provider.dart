import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  static const String boxName = "budgets";

  late Box<BudgetModel> _box;

  List<BudgetModel> get budgets => _box.values.toList();

  Future<void> init() async {
    _box = await Hive.openBox<BudgetModel>(boxName);
    notifyListeners();
  }

  Future<void> addBudget(BudgetModel model) async {
    await _box.add(model);
    notifyListeners();
  }

  Future<void> updateBudget(int key, BudgetModel model) async {
    await _box.put(key, model);
    notifyListeners();
  }

  Future<void> deleteBudget(int key) async {
    await _box.delete(key);
    notifyListeners();
  }

  BudgetModel? getByKey(int key) {
    return _box.get(key);
  }
}
