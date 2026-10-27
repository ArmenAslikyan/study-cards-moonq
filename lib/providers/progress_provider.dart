import 'package:flutter/foundation.dart';
import 'package:study_cards_moonq/domain/i_storage_repo.dart';
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/models/package.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._storage);

  final IStorageRepo _storage;

  String _key(int packageId, Flashcards card) => '$packageId:${card.id}';

  bool isKnown(int packageId, Flashcards card) =>
      _storage.progress[_key(packageId, card)]?['known'] == true;

  bool needsReview(int packageId, Flashcards card) =>
      _storage.progress[_key(packageId, card)]?['needsReview'] == true;

  bool wasStudied(int packageId, Flashcards card) =>
      _storage.progress.containsKey(_key(packageId, card));

  int get learnedToday => _storage.progress.values
      .where((item) => item['known'] == true && item['date'] == _today)
      .length;

  int get streak => _storage.streak;

  String get _today => DateTime.now().toIso8601String().substring(0, 10);

  int getLearnedCount(Package package) {
    return package.flashcards
        .where((card) => isKnown(package.id, card))
        .length;
  }

  double getPackageProgress(Package package) {
    if (package.cardNumber == 0) return 0.0;
    return getLearnedCount(package) / package.cardNumber;
  }

  int getDueCount(List<Package> packages) {
    var count = 0;
    for (final package in packages) {
      for (final card in package.flashcards) {
        if (needsReview(package.id, card)) {
          count++;
        }
      }
    }
    return count;
  }

  bool hasCardsToReview(List<Package> packages) => getDueCount(packages) > 0;

  bool hasUnstudiedCards(List<Package> packages) {
    return packages.any(
      (package) => package.flashcards.any(
        (card) => !wasStudied(package.id, card),
      ),
    );
  }

  Future<void> markKnown(
    int packageId,
    Flashcards card, {
    required bool firstAttempt,
  }) async {
    await _storage.saveProgress(_key(packageId, card), {
      'known': true,
      'needsReview': false,
      'firstAttempt': firstAttempt,
      'date': _today,
      'lastReviewed': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  Future<void> markNeedsReview(int packageId, Flashcards card) async {
    await _storage.saveProgress(_key(packageId, card), {
      'known': false,
      'needsReview': true,
      'date': _today,
      'lastReviewed': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  Future<void> resetCard(int packageId, Flashcards card) async {
    await _storage.removeProgress(_key(packageId, card));
    notifyListeners();
  }
}
