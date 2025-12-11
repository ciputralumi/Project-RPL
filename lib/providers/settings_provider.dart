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
  //bool get isDarkMode => settingsBox.get('darkMode', defaultValue: false);

  //void toggleDarkMode(bool value) {
  //  settingsBox.put('darkMode', value);
  //  notifyListeners();
  //}

  // ============================
  // CURRENCY
  // 0 = Rp, 1 = USD
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
  // FETCH API & CONVERT FUNCTION
  // ============================
  Future<void> fetchUsdRate() async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      print("Perangkat OFFLINE. Menggunakan nilai tukar fallback: $_usdRate");
      return;
    }

    final String apiUrl =
        "http://data.fixer.io/api/latest?access_key=$_fixerAccessKey&symbols=IDR,USD";

    try {
      print("Perangkat ONLINE. Mencoba fetch dari Fixer.io...");
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
            print("Fixer Rate BERHASIL Diperbarui: 1 USD = $_usdRate IDR");
          }
        } else {
          print(
              "Fixer API Error: ${data['error']['info']}. Menggunakan fallback.");
        }
      } else {
        print(
            "Gagal terhubung ke Fixer. Status: ${response.statusCode}. Menggunakan fallback.");
      }
    } catch (e) {
      print("Error saat fetch data Fixer: $e. Menggunakan fallback.");
    }
  }

  // Fungsi konversi
  double convert(double amount) {
    if (currencyFormat == 0) return amount;

    return amount / _usdRate;
  }

  double unconvert(double amount) {
    // Jika mata uangnya Rupiah (0), tidak perlu konversi.
    if (currencyFormat == 0) return amount;

    // Jika mata uangnya USD (1), kalikan dengan _usdRate
    // Jumlah yang Disimpan = Jumlah Input * Nilai Tukar
    return amount * _usdRate;
  }

  // ============================
  // RESET TRANSAKSI
  // ============================
  Future<void> clearAllTransactions() async {
    await transactionBox.clear();
    await transactionProvider.clearAllTransactions();
    notifyListeners();
  }

  Future<void> clearAllAccounts() async {
    await accountBox.clear();
    notifyListeners();
  }

  Future<void> clearAllBudgets() async {
    await budgetBox.clear();
    notifyListeners();
  }
  Future<void> clearAllGoalsAndLogs() async {
    await savingGoalBox.clear(); // Menghapus semua target
    await savingLogBox.clear(); // Menghapus semua log
    notifyListeners();
  }
  //Future<void> clearAllCategories() async {
  //  await transactionBox.clear();
  //  notifyListeners();
  //}

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
