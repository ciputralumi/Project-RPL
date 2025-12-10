import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../main_navigation.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool obscurePass = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ============================================================
              // BLUE HEADER
              // ============================================================
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
                  children: const [
                    Icon(Icons.person_add_alt_1_rounded,
                        size: 60, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      "Daftar Akun Baru",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Ayo buat akun untuk mulai mengelola keuanganmu!",
                      style: TextStyle(color: Colors.white70),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ============================================================
              // REGISTER CARD
              // ============================================================
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
                        "Daftar Sekarang",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= NAME =================
                    const Text("Nama Lengkap",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: _inputStyle(
                        "Masukkan nama lengkap",
                        Icons.person_outline,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ================= EMAIL =================
                    const Text("Email",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailController,
                      decoration: _inputStyle(
                        "nama@email.com",
                        Icons.email_outlined,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ================= PASSWORD =================
                    const Text("Password",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passController,
                      obscureText: obscurePass,
                      decoration: _passwordInput(
                        obscurePass,
                        () => setState(() => obscurePass = !obscurePass),
                        "Buat password",
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ================= CONFIRM PASSWORD =================
                    const Text("Konfirmasi Password",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: confirmPassController,
                      obscureText: obscureConfirm,
                      decoration: _passwordInput(
                        obscureConfirm,
                        () => setState(() => obscureConfirm = !obscureConfirm),
                        "Ulangi password",
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =====================================================
                    // REGISTER BUTTON — FIXED & WORKING
                    // =====================================================
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final auth = context.read<AuthProvider>();

                          if (passController.text.trim() !=
                              confirmPassController.text.trim()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Password tidak cocok"),
                              ),
                            );
                            return;
                          }

                          final result = auth.register(
                            nameController.text.trim(),
                            emailController.text.trim(),
                            passController.text.trim(),
                          );

                          if (result != null) {
                            // REGISTER GAGAL
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result)),
                            );
                          } else {
                            // REGISTER SUKSES → MASUK APP
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainNavigation(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B6BFF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Daftar  →",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // BACK TO LOGIN
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text.rich(
                          TextSpan(
                            text: "Sudah punya akun? ",
                            children: [
                              TextSpan(
                                text: "Masuk",
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT STYLES
  // ============================================================
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration _passwordInput(
      bool obscure, VoidCallback toggle, String hint) {
    return InputDecoration(
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: toggle,
      ),
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
