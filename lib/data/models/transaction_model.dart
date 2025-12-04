import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final double amount;

  @HiveField(1)
  final bool isIncome;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String note;

  @HiveField(4)
  final DateTime date;

  /// Account ID (Hive key of AccountModel)
  @HiveField(5)
  final int accountId;

  /// NEW: Id unik untuk transfer (menghubungkan Transfer Out & Transfer In)
  @HiveField(6)
  final String? transferGroupId;

  TransactionModel({
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.note,
    required this.date,
    required this.accountId,
    this.transferGroupId,
  });

  TransactionModel copyWith({
    double? amount,
    bool? isIncome,
    String? category,
    String? note,
    DateTime? date,
    int? accountId,
    String? transferGroupId,
  }) {
    return TransactionModel(
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      transferGroupId: transferGroupId ?? this.transferGroupId,
    );
  }
}
