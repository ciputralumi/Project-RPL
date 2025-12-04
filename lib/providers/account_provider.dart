import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/models/account_model.dart';
import '../data/models/transaction_model.dart';

class AccountProvider extends ChangeNotifier {
  static const String boxName = "accounts_box";

  late Box<AccountModel> _box;
  List<AccountModel> _accounts = [];

  List<AccountModel> get accounts => _accounts;

  // -------------------------------------------------------
  // INIT
  // -------------------------------------------------------
  Future<void> init() async {
    _box = Hive.box<AccountModel>(boxName);
    _accounts = _box.values.toList();
    notifyListeners();
  }

  // -------------------------------------------------------
  // CRUD
  // -------------------------------------------------------

  Future<void> addAccount(AccountModel acc) async {
    await _box.add(acc);
    _accounts = _box.values.toList();
    notifyListeners();
  }

  Future<void> updateAccount(int key, AccountModel acc) async {
    await _box.put(key, acc);
    _accounts = _box.values.toList();
    notifyListeners();
  }

  Future<void> deleteAccount(int key) async {
    await _box.delete(key);
    _accounts = _box.values.toList();
    notifyListeners();
  }

  AccountModel? getByKey(int key) {
    return _box.get(key);
  }

  AccountModel? getById(int id) {
    return _box.get(id);
  }

  // -------------------------------------------------------
  // AUTO BALANCE SYNC WITH TRANSACTIONS
  // -------------------------------------------------------

  /// Dipanggil ketika transaksi BARU ditambahkan
  Future<void> applyTransaction(TransactionModel tx) async {
    final acc = getByKey(tx.accountId);
    if (acc == null) return;

    double newBalance = acc.balance;

    if (tx.isIncome) {
      newBalance += tx.amount;
    } else {
      newBalance -= tx.amount;
    }

    final updated = AccountModel(
      name: acc.name,
      bank: acc.bank, // FIXED
      balance: newBalance,
    );

    await updateAccount(tx.accountId, updated);
  }

  /// Dipanggil saat transaksi DIHAPUS → kembalikan nilai sebelumnya
  Future<void> revertTransaction(TransactionModel tx) async {
    final acc = getByKey(tx.accountId);
    if (acc == null) return;

    double newBalance = acc.balance;

    if (tx.isIncome) {
      newBalance -= tx.amount;
    } else {
      newBalance += tx.amount;
    }

    final updated = AccountModel(
      name: acc.name,
      bank: acc.bank, // FIXED
      balance: newBalance,
    );

    await updateAccount(tx.accountId, updated);
  }

  /// Dipanggil saat transaksi DI-EDIT
  Future<void> updateTransaction({
    required TransactionModel oldTx,
    required TransactionModel newTx,
  }) async {
    // Step 1 — undo saldo transaksi lama
    await revertTransaction(oldTx);

    // Step 2 — apply transaksi baru
    await applyTransaction(newTx);

    notifyListeners();
  }
}
