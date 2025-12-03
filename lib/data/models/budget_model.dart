import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 20)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String category;

  @HiveField(1)
  double maxBudget;

  @HiveField(2)
  String goalName; // tambahan!!!

  BudgetModel({
    required this.category,
    required this.maxBudget,
    required this.goalName,
  });
}
