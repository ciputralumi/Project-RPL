import 'package:hive/hive.dart';

part 'saving_log_model.g.dart';

@HiveType(typeId: 41)
class SavingLogModel extends HiveObject {
  @HiveField(0)
  int goalKey;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String note;

  @HiveField(4)
  int? transactionKey; // Hive key of the related transaction

  SavingLogModel({
    required this.goalKey,
    required this.amount,
    required this.date,
    this.note = "",
    this.transactionKey,
  });
}
