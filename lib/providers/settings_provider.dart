import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/transaction_model.dart';

class SettingsProvider extends ChangeNotifier {
  final Box settingsBox = Hive.box('settings');
  final Box<TransactionModel> transactionBox =
      Hive.box<TransactionModel>('transactions');

  // ============================
  // DARK MODE
  // ============================
  bool get isDarkMode => settingsBox.get('darkMode', defaultValue: false);

  void toggleDarkMode(bool value) {
    settingsBox.put('darkMode', value);
    notifyListeners();
  }

  // ============================
  // CURRENCY
  // 0 = Rp, 1 = USD
  // ============================
  int get currencyFormat =>
      settingsBox.get('currencyFormat', defaultValue: 0);

  void toggleCurrencyFormat(int value) {
    settingsBox.put('currencyFormat', value);
    notifyListeners();
  }

  String get currencySymbol {
    switch (currencyFormat) {
      case 1:
        return "\$ ";
      default:
        return "Rp ";
    }
  }

  // ============================
  // CONVERT FUNCTION (PENTING!)
  // Rupiah → USD
  // ============================
  double convert(double amount) {
    // Jika Rp → tidak konversi
    if (currencyFormat == 0) return amount;

    // Jika USD → convert
    const double usdRate = 15700; // ubah sesuai kebutuhan
    return amount / usdRate;
  }

  // ============================
  // RESET TRANSAKSI
  // ============================
  Future<void> clearAllTransactions() async {
    await transactionBox.clear();
    notifyListeners();
  }

  // ============================
  // DEFAULT CATEGORIES
  // ============================
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
