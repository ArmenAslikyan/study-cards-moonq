import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_cards_moonq/domain/i_storage_repo.dart';
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/models/package.dart';

class StorageRepo implements IStorageRepo {
  static const String _progressKey = 'card_progress';
  static const String _packagesKey = 'added_packages';
  static const String _historyKey = 'studied_dates_history';
  static const String _customKey = 'custom_packages_data';

  Map<String, Map<String, dynamic>> _progress = {};
  Set<int> _addedPackageIds = {};
  Set<String> _studiedDates = {};
  bool _loaded = false;
  late SharedPreferences _prefs;

  bool get isLoaded => _loaded;

  @override
  Map<String, Map<String, dynamic>> get progress => _progress;

  @override
  Set<int> get addedPackageIds => _addedPackageIds;

  @override
  Set<String> get studiedDates => _studiedDates;

  String _formatDate(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }

  @override
  int get streak {
    List<String> allDates = [];
    for (String date in _studiedDates) {
      allDates.add(date);
    }
    for (Map<String, dynamic> card in _progress.values) {
      String? cardDate = card['date'];
      if (cardDate != null && !allDates.contains(cardDate)) {
        allDates.add(cardDate);
      }
    }
    if (allDates.isEmpty) {
      return 0;
    }
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    String todayText = _formatDate(now);
    String yesterdayText = _formatDate(yesterday);
    DateTime checkDay;
    if (allDates.contains(todayText)) {
      checkDay = now;
    } else if (allDates.contains(yesterdayText)) {
      checkDay = yesterday;
    } else {
      return 0;
    }
    int streakCount = 0;
    while (allDates.contains(_formatDate(checkDay))) {
      streakCount = streakCount + 1;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }
    return streakCount;
  }

  @override
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    String? rawProgress = _prefs.getString(_progressKey);
    if (rawProgress != null) {
      Map<String, dynamic> decoded = jsonDecode(rawProgress);
      _progress = {};
      for (String key in decoded.keys) {
        _progress[key] = Map<String, dynamic>.from(decoded[key]);
      }
    }
    List<String>? rawPackageIds = _prefs.getStringList(_packagesKey);
    if (rawPackageIds != null) {
      _addedPackageIds = {};
      for (String idString in rawPackageIds) {
        int? id = int.tryParse(idString);
        if (id != null) {
          _addedPackageIds.add(id);
        }
      }
    }
    List<String>? rawHistory = _prefs.getStringList(_historyKey);
    if (rawHistory != null) {
      _studiedDates = rawHistory.toSet();
    }
    for (Map<String, dynamic> card in _progress.values) {
      String? date = card['date'];
      if (date != null && date.isNotEmpty) {
        _studiedDates.add(date);
      }
    }
    _loaded = true;
  }

  @override
  Future<void> saveProgress(String key, Map<String, dynamic> value) async {
    _progress[key] = value;
    String? date = value['date'];
    if (date != null && date.isNotEmpty) {
      _studiedDates.add(date);
    }
    String progressJson = jsonEncode(_progress);
    await _prefs.setString(_progressKey, progressJson);
    List<String> datesList = _studiedDates.toList();
    await _prefs.setStringList(_historyKey, datesList);
  }

  @override
  Future<void> removeProgress(String key) async {
    _progress.remove(key);
    String progressJson = jsonEncode(_progress);
    await _prefs.setString(_progressKey, progressJson);
  }

  @override
  Future<void> saveAddedPackages(Set<int> ids) async {
    _addedPackageIds = ids;
    List<String> idStrings = [];
    for (int id in ids) {
      idStrings.add(id.toString());
    }
    await _prefs.setStringList(_packagesKey, idStrings);
  }

  @override
  Future<void> recordStudyDate(String date) async {
    _studiedDates.add(date);
    List<String> datesList = _studiedDates.toList();
    await _prefs.setStringList(_historyKey, datesList);
  }

  @override
  Future<void> saveCustomPackages(List<Package> packages) async {
    List<Map<String, dynamic>> packagesToSave = [];
    for (Package package in packages) {
      List<Map<String, String>> cardsToSave = [];
      for (Flashcards card in package.flashcards) {
        cardsToSave.add({
          'id': card.id,
          'armenianWord': card.armenianWord,
          'pronunciation': card.pronunciation,
          'englishTranslation': card.englishTranslation,
          'exampleSentence': card.exampleSentence,
          'exampleSentenceArmenian': card.exampleSentenceArmenian,
        });
      }
      packagesToSave.add({
        'id': package.id,
        'title': package.title,
        'cards': cardsToSave,
      });
    }
    String jsonString = jsonEncode(packagesToSave);
    await _prefs.setString(_customKey, jsonString);
  }

  @override
  Future<List<Package>> loadCustomPackages() async {
    String? jsonString = _prefs.getString(_customKey);
    if (jsonString == null) {
      return [];
    }
    try {
      List<dynamic> list = jsonDecode(jsonString);
      List<Package> loadedPackages = [];
      for (var item in list) {
        int packageId = item['id'];
        String packageTitle = item['title'];
        List<dynamic> cardsList = item['cards'] ?? [];
        List<Flashcards> flashcards = [];
        for (var cardItem in cardsList) {
          flashcards.add(
            Flashcards(
              id: cardItem['id'],
              armenianWord: cardItem['armenianWord'] ?? '',
              pronunciation: cardItem['pronunciation'] ?? '',
              englishTranslation: cardItem['englishTranslation'] ?? '',
              exampleSentence: cardItem['exampleSentence'] ?? '',
              exampleSentenceArmenian: cardItem['exampleSentenceArmenian'] ?? '',
            ),
          );
        }
        loadedPackages.add(
          Package(
            id: packageId,
            title: packageTitle,
            flashcards: flashcards,
            icon: const Icon(Icons.school),
            iconColor: const Icon(Icons.circle, color: Colors.white),
            iconBackground: const Color(0xFFC2185B),
          ),
        );
      }
      return loadedPackages;
    } catch (error) {
      return [];
    }
  }
}
