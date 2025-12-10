import 'package:hive/hive.dart';

part 'monthly_budget_model.g.dart';

@HiveType(typeId: 30)
class MonthlyBudgetModel extends HiveObject {
  @HiveField(0)
  String category;

  @HiveField(1)
  double limit;

  @HiveField(2)
  int month; // 1–12

  @HiveField(3)
  int year; // 2025

  MonthlyBudgetModel({
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });
}
