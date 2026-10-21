import 'package:flutter/foundation.dart';
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/providers/storage_provider.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._storage);
  final StorageProvider _storage;
  String _key(int packageId, Flashcards card) => '$packageId:${card.id}';
  bool isKnown(int packageId, Flashcards card) => _storage.progress[_key(packageId, card)]?['known'] == true;
  bool needsReview(int packageId, Flashcards card) => _storage.progress[_key(packageId, card)]?['needsReview'] == true;
  bool wasStudied(int packageId, Flashcards card) => _storage.progress.containsKey(_key(packageId, card));
  int get learnedToday => _storage.progress.values.where((item) => item['date'] == _today).length;
  String get _today => DateTime.now().toIso8601String().substring(0, 10);

  Future<void> markKnown(int packageId, Flashcards card, {required bool firstAttempt}) async {
    await _storage.saveProgress(_key(packageId, card), {'known': true, 'needsReview': false, 'firstAttempt': firstAttempt, 'date': _today, 'lastReviewed': DateTime.now().toIso8601String()});
    notifyListeners();
  }

  Future<void> markNeedsReview(int packageId, Flashcards card) async {
    await _storage.saveProgress(_key(packageId, card), {'known': false, 'needsReview': true, 'date': _today, 'lastReviewed': DateTime.now().toIso8601String()});
    notifyListeners();
  }

  Future<void> resetCard(int packageId, Flashcards card) async {
    await _storage.removeProgress(_key(packageId, card));
    notifyListeners();
  }
}
