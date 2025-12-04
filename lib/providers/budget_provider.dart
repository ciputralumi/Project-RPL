import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  static const String boxName = "budgets_box";

  late Box<BudgetModel> _box;

  List<BudgetModel> get budgets => _box.values.toList();

  Future<void> init() async {
    _box = await Hive.openBox<BudgetModel>(boxName);
    notifyListeners();
  }

  // ============================================================
  /// ADD NEW BUDGET
  // ============================================================
  Future<void> addBudget(BudgetModel b) async {
    await _box.add(b);
    notifyListeners();
  }

  // ============================================================
  /// UPDATE EXISTING BUDGET
  // ============================================================
  Future<void> updateBudget(int keyId, BudgetModel updated) async {
    await _box.put(keyId, updated);
    notifyListeners();
  }

  // ============================================================
  /// DELETE BUDGET
  // ============================================================
  Future<void> deleteBudget(int keyId) async {
    await _box.delete(keyId);
    notifyListeners();
  }
}
