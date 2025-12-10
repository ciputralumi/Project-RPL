// lib/presentation/auth/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_page.dart';
import '../main_navigation.dart';

/// Simple auth wrapper: kalau sudah login -> MainNavigation
/// kalau belum -> LoginPage
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // jika butuh splash/cek async, bisa return a loader while checking
    if (auth.isLoggedIn) {
      return const MainNavigation();
    } else {
      return const LoginPage();
    }
  }
}
