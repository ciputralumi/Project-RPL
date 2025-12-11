import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../themes/category_colors.dart';
import '../profile/profile_page.dart';
import '../auth/login_page.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/saving_goal_provider.dart';



class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF448AFF),
        foregroundColor: Colors.black87,
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ------------------------------------------------
          // USER HEADER + FOTO PROFIL
          // ------------------------------------------------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,

                  // FOTO PROFIL DARI HIVE
                  backgroundImage: (user?.profileImage != null &&
                          File(user!.profileImage!).existsSync())
                      ? FileImage(File(user.profileImage!))
                      : null,

                  // DEFAULT ICON
                  child: (user?.profileImage == null ||
                          !(File(user!.profileImage!).existsSync()))
                      ? const Icon(Icons.person, size: 35, color: Colors.blue)
                      : null,
                ),

                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? "User",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? "Email tidak ditemukan",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          // PROFIL SAYA BUTTON
          Container(
            decoration: _cardDecoration(),
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text(
                "Profil Saya",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfilePage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          _sectionTitle("Appearance"),

          // DARK MODE
          _settingCard(
            title: "Dark Mode",
            trailing: Switch(
              value: settings.isDarkMode,
              activeColor: Colors.white,
              activeTrackColor: Colors.black87,
              onChanged: (v) => settings.toggleDarkMode(v),
            ),
          ),

          const SizedBox(height: 20),
          _sectionTitle("Currency"),

          // CURRENCY SELECTOR
          _currencyCard(settings),

          const SizedBox(height: 26),
          _sectionTitle("Categories"),

          // CATEGORY MANAGER
          _categoryManager(context),

          const SizedBox(height: 28),

          // LOGOUT
          Container(
            decoration: _cardDecoration(),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                // CLEAR REMEMBER ME
                Hive.box('settings').put('remember_me', false);

                // HAPUS USER
                auth.logout();

                // ARAHKAN KE LOGIN PAGE
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // RESET DATA
          _dangerButton(
            label: "Reset Semua Data",
            onPressed: () => _confirmReset(context),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ============================================================
  // COMPONENT HELPERS
  // ============================================================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Color(0xFF303742),
        ),
      ),
    );
  }

  Widget _settingCard({required String title, required Widget trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // ================================
  // CURRENCY SELECTOR
  // ================================
  Widget _currencyCard(SettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _currencyChip("Rp", 0, settings),
          const SizedBox(width: 10),
          _currencyChip("\$", 1, settings),
        ],
      ),
    );
  }

  Widget _currencyChip(String label, int index, SettingsProvider settings) {
    final active = settings.currencyFormat == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => settings.toggleCurrencyFormat(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? Colors.blueAccent : const Color(0xFFE0E0E0),
              width: 1.3,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ================================
  // CATEGORY MANAGER
  // ================================
  Widget _categoryManager(BuildContext context) {
    final categories = CategoryColors.mapKeys;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          ...categories.map((cat) {
            final color = CategoryColors.getColor(cat);

            return Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(
                    cat,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _renameCategory(context, cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(context, cat),
                      )
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
            );
          }).toList(),

          TextButton.icon(
            onPressed: () => _addCategory(context),
            icon: const Icon(Icons.add),
            label: const Text("Tambah Kategori"),
          ),
        ],
      ),
    );
  }

  // ================================
  // CARD DECORATION
  // ================================
  BoxDecoration _cardDecoration() { //() - > harus da isi st 
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // ================================
  // DANGER BUTTON
  // ================================
  Widget _dangerButton({required String label, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  // ================================
  // CATEGORY DIALOGS
  // ================================
  void _addCategory(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Kategori"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nama kategori"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                CategoryColors.addCategory(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Tambah"),
          ),
        ],
      ),
    );
  }

  void _renameCategory(BuildContext context, String oldName) {
    final controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ubah Nama Kategori"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              CategoryColors.renameCategory(oldName, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(BuildContext context, String cat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Kategori?"),
        content: Text("Kategori \"$cat\" akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              CategoryColors.removeCategory(cat);
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // ================================
  // RESET DATA
  // ================================
  void _confirmReset(BuildContext context) {
    final settings = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Reset Semua Data?"),
          content: const Text(
              "Semua transaksi akan dihapus dan tidak bisa dikembalikan."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
           ElevatedButton(
  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  onPressed: () async {
    await settings.resetAllData();

    // =============================
    // FORCE REFRESH SEMUA PROVIDER
    // =============================
    Provider.of<AccountProvider>(context, listen: false).reloadAccounts();
    Provider.of<TransactionProvider>(context, listen: false).notifyListeners();
    Provider.of<SavingGoalProvider>(context, listen: false).reloadGoals();

    Navigator.pop(context);

    // OPTIONAL: Snackbar biar user tahu data selesai direset
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Semua data berhasil direset")),
    );
  },
  child: const Text("Reset"),
),

          ],
        );
      },
    );
  }
}
