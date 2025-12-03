import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String note;

  @HiveField(2)
  String category;

  @HiveField(3)
  double amount;

  @HiveField(4)
  bool isIncome;

  @HiveField(5)
  DateTime date;

  TransactionModel({
    required this.id,
    required this.note,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}
