import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 10)
class UserModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final String? profileImage; // path foto profil

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    this.profileImage,
  });
}
