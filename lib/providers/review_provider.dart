import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:study_cards_moonq/core/packages.dart' as catalog;
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/models/package.dart';
import 'package:study_cards_moonq/providers/progress_provider.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider({Package? package, this.progress})
      : _package = package ?? catalog.packages.first {
    restart();
  }

  Package _package;
  final ProgressProvider? progress;
  late List<Flashcards> _cards;
  List<Flashcards> _sessionCards = [];
  bool _isMixedReview = false;
  final Map<String, int> _cardPackageIds = {};
  final Set<String> _repeatedCardIds = {};
  int _sessionTotalCount = 0;
  int _currentIndex = 0;
  int _knownCount = 0;
  int _repeatCount = 0;
  int _passedCount = 0;
  int _firstAttemptCount = 0;
  bool _isFlipped = false;

  Package get package => _package;
  List<Flashcards> get cards => List.unmodifiable(_cards);
  Flashcards? get currentCard => _cards.isEmpty ? null : _cards[_currentIndex];
  int get totalCount => _sessionTotalCount;
  int get remainingCount => _cards.length;
  int get currentProgress => _passedCount.clamp(0, totalCount);
  int get knownCount => _knownCount;
  int get repeatCount => _repeatCount;
  int get firstAttemptCount => _firstAttemptCount;
  bool get isFinished => _cards.isEmpty;
  bool get isMixedReview => _isMixedReview;
  bool get isFlipped => _isFlipped;

  String get sessionTitle => _isMixedReview ? 'Խառը կրկնություն' : _package.title;
  String get sessionSubtitle =>
      _isMixedReview ? 'Կրկնության հերթ' : 'Փաթեթի կրկնություն';

  void toggleFlip() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  void resetFlip() {
    _isFlipped = false;
    notifyListeners();
  }

  void selectPackage(Package package) {
    _package = package;
    restart();
  }

  void startDueReview(List<Package> packages) {
    _isMixedReview = true;
    _cards = [];
    _cardPackageIds.clear();
    _repeatedCardIds.clear();
    for (final package in packages) {
      for (final card in package.flashcards) {
        if (progress?.needsReview(package.id, card) ?? false) {
          _cards.add(card);
          _cardPackageIds[card.id] = package.id;
        }
      }
    }
    _sessionTotalCount = _cards.length;
    _sessionCards = List.of(_cards);
    _currentIndex = 0;
    _knownCount = 0;
    _repeatCount = 0;
    _passedCount = 0;
    _firstAttemptCount = 0;
    _isFlipped = false;
    notifyListeners();
  }

  void restart() {
    _isMixedReview = false;
    _cards = _package.flashcards
        .where((card) => !(progress?.isKnown(_package.id, card) ?? false))
        .toList();
    _cardPackageIds
      ..clear()
      ..addEntries(_cards.map((card) => MapEntry(card.id, _package.id)));
    _repeatedCardIds.clear();
    _sessionTotalCount = _cards.length;
    _sessionCards = List.of(_cards);
    _currentIndex = 0;
    _knownCount = 0;
    _repeatCount = 0;
    _passedCount = 0;
    _firstAttemptCount = 0;
    _isFlipped = false;
    notifyListeners();
  }

  void shuffle() {
    _cards.shuffle(Random());
    _currentIndex = 0;
    _isFlipped = false;
    notifyListeners();
  }

  Future<void> restartCurrentSession() async {
    for (final card in _sessionCards) {
      await progress?.resetCard(
        _cardPackageIds[card.id] ?? _package.id,
        card,
      );
    }
    _cards = List<Flashcards>.of(_sessionCards);
    _sessionTotalCount = _cards.length;
    _currentIndex = 0;
    _knownCount = 0;
    _repeatCount = 0;
    _passedCount = 0;
    _repeatedCardIds.clear();
    _firstAttemptCount = 0;
    _isFlipped = false;
    notifyListeners();
  }

  void markKnown() {
    if (_cards.isEmpty) return;
    final card = _cards[_currentIndex];
    final isFirstAttempt = !_repeatedCardIds.contains(card.id);
    if (isFirstAttempt) {
      _firstAttemptCount++;
    }

    _cards.removeAt(_currentIndex);
    _knownCount++;
    _passedCount++;
    _isFlipped = false;
    if (_cards.isNotEmpty && _currentIndex >= _cards.length) _currentIndex = 0;
    progress?.markKnown(
      _cardPackageIds[card.id] ?? _package.id,
      card,
      firstAttempt: isFirstAttempt,
    );
    notifyListeners();
  }

  void markRepeat() {
    if (_cards.isEmpty) return;
    final card = _cards.removeAt(_currentIndex);
    _repeatedCardIds.add(card.id);
    _cards.add(card);
    _repeatCount++;
    _passedCount++;
    _isFlipped = false;
    if (_currentIndex >= _cards.length) _currentIndex = 0;
    progress?.markNeedsReview(_cardPackageIds[card.id] ?? _package.id, card);
    notifyListeners();
  }
}
