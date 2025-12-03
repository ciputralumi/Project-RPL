import 'package:flutter/material.dart';

class CategoryColors {
  // Default kategori + warna
  static final Map<String, Color> _map = {
    "Makanan & Minuman": const Color(0xFF6C5CE7),
    "Transportasi": const Color(0xFF00B894),
    "Belanja": const Color(0xFFFF7675),
    "Rumah": const Color(0xFFFFD166),
    "Gaji": const Color(0xFF4CAF50),
    "Hiburan": const Color(0xFF74B9FF),
    "Lainnya": const Color(0xFF2F4CFF),
  };

  /// Getter untuk ambil list nama kategori
  static List<String> get mapKeys => _map.keys.toList();

  /// Ambil warna berdasarkan kategori
  static Color getColor(String category) {
    return _map[category] ?? _default();
  }

  static Color _default() {
    return const Color(0xFF2F4CFF);
  }

  /// Tambah kategori (default color = biru)
  static void addCategory(String category) {
    if (!_map.containsKey(category)) {
      _map[category] = _default();
    }
  }

  /// Rename kategori lama → baru (keep warna lama)
  static void renameCategory(String oldName, String newName) {
    if (_map.containsKey(oldName)) {
      final color = _map[oldName]!;
      _map.remove(oldName);
      _map[newName] = color;
    }
  }

  /// Hapus kategori
  static void removeCategory(String category) {
    if (_map.containsKey(category)) {
      _map.remove(category);
    }
  }
}
