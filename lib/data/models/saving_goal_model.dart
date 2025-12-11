import 'package:hive/hive.dart';

part 'saving_goal_model.g.dart';

@HiveType(typeId: 40)
class SavingGoalModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double target;

  @HiveField(2)
  double saved;

  @HiveField(3)
  DateTime? deadline;

  SavingGoalModel({
    required this.title,
    required this.target,
    this.saved = 0,
    this.deadline,
  });
}