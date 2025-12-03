
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/transaction_model.dart';

class SettingsProvider extends ChangeNotifier {
  final Box settingsBox = Hive.box('settings');
  final Box<TransactionModel> transactionBox =
      Hive.box<TransactionModel>('transactions');

  bool get isDarkMode => settingsBox.get('darkMode', defaultValue: false);

  void toggleDarkMode(bool value) {
    settingsBox.put('darkMode', value);
    notifyListeners();
  }

  int get currencyFormat =>
      settingsBox.get('currencyFormat', defaultValue: 0);

  void toggleCurrencyFormat(int value) {
    settingsBox.put('currencyFormat', value);
    notifyListeners();
  }

  String get currencySymbol {
    switch (currencyFormat) {
      case 1:
        return "\$";
      default:
        return "Rp";
    }
  }

  Future<void> clearAllTransactions() async {
    await transactionBox.clear();
    notifyListeners();
  }

  // ================================
  // CATEGORIES (Default)
  // ================================
  List<String> get categories => [
    "Makanan & Minuman",
    "Transportasi",
    "Belanja",
    "Rumah",
    "Gaji",
    "Hiburan",
    "Lainnya",
  ];
}

