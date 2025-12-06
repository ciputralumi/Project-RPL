import 'package:flutter/material.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  final List<UserModel> _dummyUsers = [];

  // REGISTER
  String? register(String name, String email, String password) {
    if (_dummyUsers.any((u) => u.email == email)) {
      return "Email sudah digunakan";
    }

    final user = UserModel(
      name: name,
      email: email,
      password: password,
    );

    _dummyUsers.add(user);
    _currentUser = user;

    notifyListeners();
    return null;
  }

  // LOGIN
  String? login(String email, String password) {
    try {
      final user = _dummyUsers.firstWhere((u) => u.email == email);

      if (user.password != password) {
        return "Password salah";
      }

      _currentUser = user;
      notifyListeners();
      return null;
    } catch (_) {
      return "Akun tidak ditemukan";
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
