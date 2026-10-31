import 'package:flutter/foundation.dart';
import 'package:study_cards_moonq/domain/i_storage_repo.dart';
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/models/package.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._storage);

  final IStorageRepo _storage;

  String _cardKey(int packageId, Flashcards card) {
    return '$packageId:${card.id}';
  }

  String get _todayDate {
    return DateTime.now().toIso8601String().substring(0, 10);
  }

  bool isKnown(int packageId, Flashcards card) {
    final key = _cardKey(packageId, card);
    final cardData = _storage.progress[key];
    if (cardData == null) {
      return false;
    }
    return cardData['known'] == true;
  }

  bool needsReview(int packageId, Flashcards card) {
    final key = _cardKey(packageId, card);
    final cardData = _storage.progress[key];
    if (cardData == null) {
      return false;
    }
    return cardData['needsReview'] == true;
  }

  bool wasStudied(int packageId, Flashcards card) {
    final key = _cardKey(packageId, card);
    return _storage.progress.containsKey(key);
  }

  int get streak {
    return _storage.streak;
  }

  int get learnedToday {
    int total = 0;
    for (final cardInfo in _storage.progress.values) {
      final isCardKnown = cardInfo['known'] == true;
      final isStudiedToday = cardInfo['date'] == _todayDate;
      if (isCardKnown && isStudiedToday) {
        total = total + 1;
      }
    }
    return total;
  }

  int getLearnedCount(Package package) {
    int count = 0;
    for (final card in package.flashcards) {
      if (isKnown(package.id, card)) {
        count = count + 1;
      }
    }
    return count;
  }

  double getPackageProgress(Package package) {
    if (package.cardNumber == 0) {
      return 0.0;
    }
    return getLearnedCount(package) / package.cardNumber;
  }

  int getDueCount(List<Package> packages) {
    int totalDue = 0;
    for (final package in packages) {
      for (final card in package.flashcards) {
        if (needsReview(package.id, card)) {
          totalDue = totalDue + 1;
        }
      }
    }
    return totalDue;
  }

  bool hasCardsToReview(List<Package> packages) {
    return getDueCount(packages) > 0;
  }

  bool hasUnstudiedCards(List<Package> packages) {
    for (final package in packages) {
      for (final card in package.flashcards) {
        if (!wasStudied(package.id, card)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> markKnown(
    int packageId,
    Flashcards card, {
    required bool firstAttempt,
  }) async {
    final key = _cardKey(packageId, card);
    final data = {
      'known': true,
      'needsReview': false,
      'firstAttempt': firstAttempt,
      'date': _todayDate,
      'lastReviewed': DateTime.now().toIso8601String(),
    };
    await _storage.saveProgress(key, data);
    notifyListeners();
  }

  Future<void> markNeedsReview(int packageId, Flashcards card) async {
    final key = _cardKey(packageId, card);
    final data = {
      'known': false,
      'needsReview': true,
      'date': _todayDate,
      'lastReviewed': DateTime.now().toIso8601String(),
    };
    await _storage.saveProgress(key, data);
    notifyListeners();
  }

  Future<void> resetCard(int packageId, Flashcards card) async {
    final key = _cardKey(packageId, card);
    await _storage.removeProgress(key);
    notifyListeners();
  }
}
