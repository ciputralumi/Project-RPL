import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../../providers/auth_provider.dart';
import '../main_navigation.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool rememberMe = false;
  bool obscurePassword = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController fadeController;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();

    fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    fadeAnim = CurvedAnimation(parent: fadeController, curve: Curves.easeOut);
    fadeController.forward();

    _checkAutoLogin();
  }

  /// AUTO LOGIN menggunakan Hive (user_box)
  void _checkAutoLogin() {
    final box = Hive.box('user_box');
    final saved = box.get('remember_me', defaultValue: false);

    if (saved == true) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      });
    }
  }

  @override
  void dispose() {
    fadeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// PROSES LOGIN
  void _login(AuthProvider auth) {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showError("Email dan password wajib diisi!");
      return;
    }

    if (!email.contains("@")) {
      _showError("Format email tidak valid!");
      return;
    }

    final result = auth.login(email, pass);

    if (result == null) {
      final box = Hive.box('user_box');

      if (rememberMe) {
        // Simpan user ke Hive
        box.put('remember_me', true);
        box.put('email', auth.currentUser!.email);
        box.put('name', auth.currentUser!.name);
        box.put('password', auth.currentUser!.password);
      } else {
        // Hapus data remember me
        box.clear();
      }

      // Masuk ke home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      _showError(result);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: fadeAnim,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ===================== HEADER =====================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2B6BFF),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Finance Manager",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Kelola keuangan Anda dengan mudah",
                        style: TextStyle(color: Colors.white70),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===================== LOGIN CARD =====================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Masuk ke Akun Anda",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email
                      const Text("Email",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "nama@email.com",
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Password
                      const Text("Password",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Masukkan password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () =>
                                setState(() => obscurePassword = !obscurePassword),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                activeColor: const Color(0xFF2B6BFF),
                                onChanged: (v) =>
                                    setState(() => rememberMe = v!),
                              ),
                              const Text("Ingat saya"),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text("Lupa password?"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _login(auth),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B6BFF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Masuk  →",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Register link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterPage()),
                            );
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: "Belum punya akun? ",
                              children: [
                                TextSpan(
                                  text: "Daftar sekarang",
                                  style: TextStyle(
                                    color: Color(0xFF2B6BFF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
