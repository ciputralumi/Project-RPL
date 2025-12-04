import 'package:hive/hive.dart';

part 'account_model.g.dart';

@HiveType(typeId: 21)
class AccountModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String bank;

  @HiveField(2)
  double balance;

  AccountModel({
    required this.name,
    required this.bank,
    required this.balance,
  });
}
