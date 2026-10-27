import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_cards_moonq/domain/i_storage_repo.dart';
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/models/package.dart';

class StorageRepo implements IStorageRepo {
  static const _progressKey = 'card_progress';
  static const _packagesKey = 'added_packages';
  static const _studiedDatesKey = 'studied_dates_history';
  static const _customPackagesKey = 'custom_packages_data';

  Map<String, Map<String, dynamic>> _progress = {};
  Set<int> _addedPackageIds = {};
  Set<String> _studiedDates = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  @override
  Map<String, Map<String, dynamic>> get progress => Map.unmodifiable(_progress);

  @override
  Set<int> get addedPackageIds => Set.unmodifiable(_addedPackageIds);

  @override
  Set<String> get studiedDates => Set.unmodifiable(_studiedDates);

  @override
  int get streak {
    final allDates = Set<String>.from(_studiedDates);
    for (final item in _progress.values) {
      final date = item['date'];
      if (date is String && date.isNotEmpty) {
        allDates.add(date);
      }
    }

    if (allDates.isEmpty) return 0;

    final now = DateTime.now();
    final today = _formatDate(now);
    final yesterday = _formatDate(now.subtract(const Duration(days: 1)));

    DateTime checkDate;
    if (allDates.contains(today)) {
      checkDate = now;
    } else if (allDates.contains(yesterday)) {
      checkDate = now.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    var count = 0;
    while (allDates.contains(_formatDate(checkDate))) {
      count++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return count;
  }

  String _formatDate(DateTime date) => date.toIso8601String().substring(0, 10);

  @override
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProgress = prefs.getString(_progressKey);
    if (rawProgress != null) {
      final decoded = jsonDecode(rawProgress) as Map<String, dynamic>;
      _progress = decoded.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
      );
    }

    _addedPackageIds =
        (prefs.getStringList(_packagesKey) ?? []).map(int.parse).toSet();

    _studiedDates = (prefs.getStringList(_studiedDatesKey) ?? []).toSet();
    for (final item in _progress.values) {
      final date = item['date'];
      if (date is String && date.isNotEmpty) {
        _studiedDates.add(date);
      }
    }

    _loaded = true;
  }

  @override
  Future<void> saveProgress(String key, Map<String, dynamic> value) async {
    _progress[key] = value;
    final date = value['date'];
    if (date is String && date.isNotEmpty) {
      _studiedDates.add(date);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(_progress));
    await prefs.setStringList(_studiedDatesKey, _studiedDates.toList());
  }

  @override
  Future<void> removeProgress(String key) async {
    _progress.remove(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(_progress));
  }

  @override
  Future<void> saveAddedPackages(Set<int> ids) async {
    _addedPackageIds = ids;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_packagesKey, ids.map((id) => '$id').toList());
  }

  @override
  Future<void> recordStudyDate(String date) async {
    _studiedDates.add(date);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_studiedDatesKey, _studiedDates.toList());
  }

  @override
  Future<void> saveCustomPackages(List<Package> packages) async {
    final prefs = await SharedPreferences.getInstance();
    final data = packages.map((pkg) => {
      'id': pkg.id,
      'title': pkg.title,
      'iconCodePoint': pkg.icon.icon?.codePoint ?? Icons.school.codePoint,
      'colorValue': pkg.iconBackground.toARGB32(),
      'flashcards': pkg.flashcards.map((card) => {
        'id': card.id,
        'armenianWord': card.armenianWord,
        'pronunciation': card.pronunciation,
        'englishTranslation': card.englishTranslation,
        'exampleSentence': card.exampleSentence,
        'exampleSentenceArmenian': card.exampleSentenceArmenian,
      }).toList(),
    }).toList();
    await prefs.setString(_customPackagesKey, jsonEncode(data));
  }

  static IconData _resolveIcon(int codePoint) {
    switch (codePoint) {
      case 0xe3ae:
        return Icons.language;
      case 0xe559:
        return Icons.school;
      case 0xe5e1:
        return Icons.science;
      case 0xe150:
        return Icons.calculate;
      case 0xe3b7:
        return Icons.menu_book;
      default:
        // ignore: non_const_argument_for_const_parameter
        return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
  }

  @override
  Future<List<Package>> loadCustomPackages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customPackagesKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        final codePoint = map['iconCodePoint'] as int? ?? Icons.school.codePoint;
        final colorValue = map['colorValue'] as int? ?? 0xFFC2185B;
        final cardsList = (map['flashcards'] as List<dynamic>?) ?? [];
        return Package(
          id: map['id'] as int,
          title: map['title'] as String,
          icon: Icon(_resolveIcon(codePoint)),
          iconColor: const Icon(Icons.circle, color: Colors.white),
          iconBackground: Color(colorValue),
          flashcards: cardsList.map((c) {
            final cardMap = c as Map<String, dynamic>;
            return Flashcards(
              id: cardMap['id'] as String?,
              armenianWord: cardMap['armenianWord'] as String? ?? '',
              pronunciation: cardMap['pronunciation'] as String? ?? '',
              englishTranslation: cardMap['englishTranslation'] as String? ?? '',
              exampleSentence: cardMap['exampleSentence'] as String? ?? '',
              exampleSentenceArmenian: cardMap['exampleSentenceArmenian'] as String? ?? '',
            );
          }).toList(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
