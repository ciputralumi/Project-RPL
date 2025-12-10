import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/saving_log_model.dart';

class SavingLogProvider extends ChangeNotifier {
  static const boxName = "saving_logs_box";

  late Box<SavingLogModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<SavingLogModel>(boxName);
    notifyListeners();
  }

  List<SavingLogModel> logsForGoal(int goalKey) {
    return _box.values
        .where((log) => log.goalKey == goalKey)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addLog(SavingLogModel log) async {
    await _box.add(log);
    notifyListeners();
  }

  Future<void> deleteLog(int key) async {
    await _box.delete(key);
    notifyListeners();
  }

  Future<void> updateLog(int key, SavingLogModel updated) async {
    await _box.put(key, updated);
    notifyListeners();
  }
}
