import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/models/monthly_budget_model.dart';

class MonthlyBudgetProvider extends ChangeNotifier {
  static const String boxName = "monthly_budgets_box";

  late Box<MonthlyBudgetModel> _box;

  List<MonthlyBudgetModel> get budgets => _box.values.toList();

  Future<void> init() async {
    _box = await Hive.openBox<MonthlyBudgetModel>(boxName);
    notifyListeners();
  }

  // ADD
  Future<void> add(MonthlyBudgetModel b) async {
    await _box.add(b);
    notifyListeners();
  }

  // UPDATE
  Future<void> update(int keyId, MonthlyBudgetModel updated) async {
    await _box.put(keyId, updated);
    notifyListeners();
  }

  // DELETE
  Future<void> delete(int keyId) async {
    await _box.delete(keyId);
    notifyListeners();
  }
}
