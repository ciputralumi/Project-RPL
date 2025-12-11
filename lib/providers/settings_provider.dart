import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/transaction_model.dart';
import '../data/models/account_model.dart';
import '../data/models/budget_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/models/saving_goal_model.dart'; 
import '../data/models/saving_log_model.dart';



class SettingsProvider extends ChangeNotifier {
  late final String _fixerAccessKey;
  final Box settingsBox = Hive.box('settings');
  final Box<TransactionModel> transactionBox =
      Hive.box<TransactionModel>('transactions');

  final Box<AccountModel> accountBox = Hive.box<AccountModel>('accounts_box');
  final Box<SavingGoalModel> savingGoalBox = Hive.box<SavingGoalModel>('saving_goals_box');
  final Box<SavingLogModel> savingLogBox = Hive.box<SavingLogModel>('saving_logs_box');
  final Box<BudgetModel> budgetBox = Hive.box<BudgetModel>('budgets_box');

  SettingsProvider() {
    try {
      _fixerAccessKey = dotenv.env['FIXER_ACCESS_KEY'] ?? '';
    } catch (e) {
      _fixerAccessKey = '';
    }
  }

  double _usdRate = 15700;
  double get usdRate => _usdRate;

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
  // ============================
  int get currencyFormat => settingsBox.get('currencyFormat', defaultValue: 0);

  void toggleCurrencyFormat(int value) {
    settingsBox.put('currencyFormat', value);
    notifyListeners();
  }

  String get currencySymbol {
    switch (currencyFormat) {
      case 1:
        return "\$";
      default:
        return "Rp ";
    }
  }

  // ============================
  // FETCH USD RATE
  // ============================
  Future<void> fetchUsdRate() async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      print("Offline → pakai fallback rate: $_usdRate");
      return;
    }

    final String apiUrl =
        "http://data.fixer.io/api/latest?access_key=$_fixerAccessKey&symbols=IDR,USD";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final rates = data['rates'];
          final double eurToIdr = (rates['IDR'] as num).toDouble();
          final double eurToUsd = (rates['USD'] as num).toDouble();
          final double calculatedUsdToIdr = eurToIdr / eurToUsd;

          if (calculatedUsdToIdr > 0) {
            _usdRate = calculatedUsdToIdr;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print("Fixer error: $e → fallback");
    }
  }

  // Konversi
  double convert(double amount) {
    if (currencyFormat == 0) return amount;
    return amount / _usdRate;
  }

  double unconvert(double amount) {
    if (currencyFormat == 0) return amount;
    return amount * _usdRate;
  }

  // ============================
  // RESET ALL DATA — FIXED
  // ============================
Future<void> resetAllData() async {
  // ========================
  // 1. Reset saldo akun → 0
  // ========================
  for (final acc in accountBox.values) {
    final key = acc.key as int;

    final updated = AccountModel(
      name: acc.name,
      type: acc.type,
      balance: 0,
    );

    await accountBox.put(key, updated);
  }

  // ========================
  // 2. HAPUS semua transaksi
  // ========================
  await transactionBox.clear();

  // ========================
  // 3. HAPUS semua budget
  // ========================
  await budgetBox.clear();

  // ========================
  // 4. HAPUS semua saving goals
  // ========================
  await savingGoalBox.clear();

  // ========================
  // 5. HAPUS semua saving logs
  // ========================
  await savingLogBox.clear();

  // ========================
  // 6. Refresh UI
  // ========================
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
