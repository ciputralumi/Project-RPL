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

  Future<void> applyTransaction(TransactionModel tx) async {
    final acc = getByKey(tx.accountId);
    if (acc == null) return;

    double newBalance = acc.balance;

    if (tx.isIncome) {
      newBalance += tx.amount;
    } else {
      if (acc.balance < tx.amount) {
        throw Exception(
          'Saldo tidak mencukupi untuk pengeluaran ini. Saldo saat ini: ${acc.balance}',
        );
      }
      newBalance -= tx.amount;
    }

    final updated = AccountModel(
      name: acc.name,
      type: acc.type,
      balance: newBalance,
    );

    await updateAccount(tx.accountId, updated);
  }

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
      type: acc.type,
      balance: newBalance,
    );

    await updateAccount(tx.accountId, updated);
  }

  Future<void> updateTransaction({
    required TransactionModel oldTx,
    required TransactionModel newTx,
  }) async {
    await revertTransaction(oldTx);
    await applyTransaction(newTx);
    notifyListeners();
  }

  // =============================================================
  // TRANSFER ANTAR AKUN
  // =============================================================
  Future<void> transfer({
    required int fromId,
    required int toId,
    required double amount,
  }) async {
    if (fromId == toId) return;

    final accFrom = getByKey(fromId);
    final accTo = getByKey(toId);

    if (accFrom == null || accTo == null) return;

    if (accFrom.balance < amount) {
      throw Exception(
        'Saldo tidak mencukupi. Saldo saat ini: ${accFrom.balance}',
      );
    }

    final newFromBalance = accFrom.balance - amount;
    final newToBalance = accTo.balance + amount;

    // Update akun asal
    await updateAccount(
      fromId,
      AccountModel(
        name: accFrom.name,
        type: accFrom.type,
        balance: newFromBalance,
      ),
    );

    // Update akun tujuan
    await updateAccount(
      toId,
      AccountModel(
        name: accTo.name,
        type: accTo.type,
        balance: newToBalance,
      ),
    );

    notifyListeners();
  }

// -------------------------------------------------------
// TOTAL BALANCE (untuk Dashboard)
// -------------------------------------------------------
double get totalBalance {
  return _accounts.fold(0.0, (sum, acc) => sum + acc.balance);
}

}
