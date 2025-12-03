import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../themes/category_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
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
          // USER HEADER
          // ------------------------------------------------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, size: 35, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Pengaturan aplikasi",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle("Appearance"),

          // ------------------------------------------------
          // DARK MODE
          // ------------------------------------------------
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

          // ------------------------------------------------
          // CURRENCY SELECTOR PREMIUM
          // ------------------------------------------------
          _currencyCard(settings),

          const SizedBox(height: 26),
          _sectionTitle("Categories"),

          // ------------------------------------------------
          // CATEGORY MANAGER
          // ------------------------------------------------
          _categoryManager(context),

          const SizedBox(height: 28),

          // ------------------------------------------------
          // RESET DATA
          // ------------------------------------------------
          _dangerButton(
            label: "Reset Semua Data",
            onPressed: () => _confirmReset(context),
          ),

          const SizedBox(height: 30),
        ],
      ),

    );
  }

  // ==============================
  // SECTION TITLE
  // ==============================
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

  // ==============================
  // SETTING CARD WRAPPER
  // ==============================
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

  // ==============================
  // CURRENCY SELECTOR PREMIUM
  // ==============================
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

  Widget _currencyChip(
      String label, int index, SettingsProvider settings) {
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

  // ==============================
  // CATEGORY MANAGER
  // ==============================
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

  // ==============================
  // RED DANGER BUTTON
  // ==============================
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

  // ==============================
  // CARD DECORATION
  // ==============================
  BoxDecoration _cardDecoration() {
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

  // -----------------------------
  // ADD CATEGORY
  // -----------------------------
  void _addCategory(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Tambah Kategori"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nama kategori"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
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
        );
      },
    );
  }

  // -----------------------------
  // RENAME CATEGORY
  // -----------------------------
  void _renameCategory(BuildContext context, String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Ubah Nama Kategori"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                CategoryColors.renameCategory(oldName, controller.text);
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // -----------------------------
  // DELETE CATEGORY
  // -----------------------------
  void _deleteCategory(BuildContext context, String cat) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Hapus Kategori?"),
          content: Text("Kategori \"$cat\" akan dihapus permanen."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                CategoryColors.removeCategory(cat);
                Navigator.pop(context);
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  // -----------------------------
  // CONFIRM RESET
  // -----------------------------
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
              onPressed: () {
                settings.clearAllTransactions();
                Navigator.pop(context);
              },
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );
  }
}
