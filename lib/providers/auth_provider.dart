import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  late Box userBox;

  AuthProvider() {
    userBox = Hive.box('user_box');
    _loadUserFromHive();
  }

  /// Dummy account
  final UserModel dummyUser = UserModel(
    name: "Erik Oppa",
    email: "erik@gmail.com",
    password: "123456",
    profileImage: null,
  );

  // ============================================================
  // AUTO LOGIN: LOAD USER DARI HIVE
  // ============================================================
  void _loadUserFromHive() {
    if (userBox.containsKey('user')) {
      final saved = userBox.get('user') as UserModel;
      _currentUser = saved;
      notifyListeners();
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================
  String? login(String email, String password) {
    // 1. cek user tersimpan di hive
    if (userBox.containsKey('user')) {
      final saved = userBox.get('user') as UserModel;

      if (saved.email == email && saved.password == password) {
        _currentUser = saved;
        notifyListeners();
        return null;
      }
    }

    // 2. cek dummy user
    if (dummyUser.email == email && dummyUser.password == password) {
      _currentUser = dummyUser;
      userBox.put('user', dummyUser);
      notifyListeners();
      return null;
    }

    return "Email atau password salah";
  }

  // ============================================================
  // REGISTER
  // ============================================================
  String? register(String name, String email, String password) {
    if (email == dummyUser.email) {
      return "Email sudah digunakan";
    }

    final newUser = UserModel(
      name: name,
      email: email,
      password: password,
      profileImage: null,
    );

    _currentUser = newUser;
    userBox.put('user', newUser);

    notifyListeners();
    return null;
  }

  // ============================================================
  // UPDATE PROFILE INFO
  // ============================================================
  String? updateUser({
    required String name,
    required String email,
  }) {
    if (_currentUser == null) return "User tidak ditemukan";

    if (email == dummyUser.email && email != _currentUser!.email) {
      return "Email sudah digunakan";
    }

    final updated = UserModel(
      name: name,
      email: email,
      password: _currentUser!.password,
      profileImage: _currentUser!.profileImage,
    );

    _currentUser = updated;
    userBox.put('user', updated);

    notifyListeners();
    return null;
  }

  // ============================================================
  // UPDATE PROFILE IMAGE
  // ============================================================
  void updateProfileImage(String path) {
    if (_currentUser == null) return;

    final updated = UserModel(
      name: _currentUser!.name,
      email: _currentUser!.email,
      password: _currentUser!.password,
      profileImage: path,
    );

    _currentUser = updated;
    userBox.put('user', updated);

    notifyListeners();
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  void logout() {
    userBox.clear();
    _currentUser = null;
    notifyListeners();
  }

  bool get isLoggedIn => _currentUser != null;
}
