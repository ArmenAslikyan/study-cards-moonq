import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageProvider extends ChangeNotifier {
  static const _progressKey = 'card_progress';
  static const _packagesKey = 'added_packages';
  Map<String, Map<String, dynamic>> _progress = {};
  Set<int> _addedPackageIds = {};
  bool _loaded = false;
  bool get isLoaded => _loaded;
  Map<String, Map<String, dynamic>> get progress => Map.unmodifiable(_progress);
  Set<int> get addedPackageIds => Set.unmodifiable(_addedPackageIds);
  int get streak {
    final dates = _progress.values
        .map((item) => item['date'])
        .whereType<String>()
        .toSet();
    var day = DateTime.now();
    var count = 0;
    while (dates.contains(_date(day))) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  String _date(DateTime date) => date.toIso8601String().substring(0, 10);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _progress = decoded.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)));
    }
    _addedPackageIds = (prefs.getStringList(_packagesKey) ?? []).map(int.parse).toSet();
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveProgress(String key, Map<String, dynamic> value) async {
    _progress[key] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(_progress));
    notifyListeners();
  }

  Future<void> removeProgress(String key) async {
    _progress.remove(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(_progress));
    notifyListeners();
  }

  Future<void> saveAddedPackages(Set<int> ids) async {
    _addedPackageIds = ids;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_packagesKey, ids.map((id) => '$id').toList());
    notifyListeners();
  }
}
