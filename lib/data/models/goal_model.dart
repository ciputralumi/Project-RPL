import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 6)
class GoalModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  double currentAmount;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? deadline;

  @HiveField(6)
  String? note;

  GoalModel({
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.category,
    required this.createdAt,
    this.deadline,
    this.note,
  });
}
