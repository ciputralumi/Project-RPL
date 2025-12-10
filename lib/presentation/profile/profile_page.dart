import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;

    nameController = TextEditingController(text: user?.name ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================
  Future<void> _pickImage(AuthProvider auth) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final newPath =
          "${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final savedFile = await File(picked.path).copy(newPath);

      auth.updateProfileImage(savedFile.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat foto")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Profil Saya",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => isEditing = true);
              },
            ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // FOTO PROFIL
          Center(
            child: GestureDetector(
              onTap: () {
                if (isEditing) _pickImage(auth);
              },
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: (user?.profileImage != null &&
                        File(user!.profileImage!).existsSync())
                    ? FileImage(File(user.profileImage!))
                    : null,
                child: (user?.profileImage == null ||
                        !(File(user!.profileImage!).existsSync()))
                    ? const Icon(Icons.person, size: 55, color: Colors.blue)
                    : null,
              ),
            ),
          ),

          if (isEditing) ...[
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Tap foto untuk mengganti",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],

          const SizedBox(height: 30),

          // NAME FIELD
          const Text(
            "Nama Lengkap",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: nameController,
            enabled: isEditing,
            decoration: _inputStyle("Masukkan nama"),
          ),

          const SizedBox(height: 20),

          // EMAIL FIELD
          const Text(
            "Email",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: emailController,
            enabled: isEditing,
            decoration: _inputStyle("Masukkan email"),
          ),

          const SizedBox(height: 32),

          // SAVE BUTTON
          if (isEditing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // simple validation
                  if (!emailController.text.contains("@")) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Format email tidak valid"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final result = auth.updateUser(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                  );

                  if (result == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profil berhasil diperbarui"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    setState(() => isEditing = false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result),
                        backgroundColor: Colors.red,
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
                  "Simpan Perubahan",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
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
