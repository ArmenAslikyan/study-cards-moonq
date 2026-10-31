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
  List<Flashcards> _cards = [];
  List<Flashcards> _sessionCards = [];
  final Map<String, int> _cardPackageIds = {};
  final Set<String> _repeatedCardIds = {};

  bool _isMixedReview = false;
  int _currentIndex = 0;
  int _knownCount = 0;
  int _repeatCount = 0;
  int _passedCount = 0;
  int _firstAttemptCount = 0;
  bool _isFlipped = false;

  Package get package => _package;
  List<Flashcards> get cards => List.unmodifiable(_cards);
  Flashcards? get currentCard => _cards.isEmpty ? null : _cards[_currentIndex];
  int get totalCount => _sessionCards.length;
  int get remainingCount => _cards.length;
  int get currentProgress => _passedCount.clamp(0, totalCount);
  int get knownCount => _knownCount;
  int get repeatCount => _repeatCount;
  int get firstAttemptCount => _firstAttemptCount;
  bool get isFinished => _cards.isEmpty;
  bool get isMixedReview => _isMixedReview;
  bool get isFlipped => _isFlipped;

  String get sessionTitle {
    if (_isMixedReview) {
      return 'Խառը կրկնություն';
    } else {
      return _package.title;
    }
  }

  String get sessionSubtitle {
    if (_isMixedReview) {
      return 'Կրկնության հերթ';
    } else {
      return 'Փաթեթի կրկնություն';
    }
  }

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
    _cards.clear();
    _cardPackageIds.clear();
    for (final package in packages) {
      for (final card in package.flashcards) {
        final needsToReview = progress?.needsReview(package.id, card) ?? false;
        if (needsToReview) {
          _cards.add(card);
          _cardPackageIds[card.id] = package.id;
        }
      }
    }
    _startFreshQueue();
  }

  void restart() {
    _isMixedReview = false;
    _cards.clear();
    _cardPackageIds.clear();
    for (final card in _package.flashcards) {
      final alreadyKnown = progress?.isKnown(_package.id, card) ?? false;
      if (!alreadyKnown) {
        _cards.add(card);
        _cardPackageIds[card.id] = _package.id;
      }
    }
    _startFreshQueue();
  }

  void _startFreshQueue() {
    _sessionCards = List.of(_cards);
    _currentIndex = 0;
    _knownCount = 0;
    _repeatCount = 0;
    _passedCount = 0;
    _firstAttemptCount = 0;
    _repeatedCardIds.clear();
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
      final packageId = _cardPackageIds[card.id] ?? _package.id;
      await progress?.resetCard(packageId, card);
    }
    _cards = List.of(_sessionCards);
    _startFreshQueue();
  }

  void markKnown() {
    if (_cards.isEmpty) return;
    final card = _cards.removeAt(_currentIndex);
    final wasFirstAttempt = !_repeatedCardIds.contains(card.id);
    if (wasFirstAttempt) {
      _firstAttemptCount = _firstAttemptCount + 1;
    }
    _knownCount = _knownCount + 1;
    _passedCount = _passedCount + 1;
    _isFlipped = false;
    if (_cards.isNotEmpty && _currentIndex >= _cards.length) {
      _currentIndex = 0;
    }
    final packageId = _cardPackageIds[card.id] ?? _package.id;
    progress?.markKnown(packageId, card, firstAttempt: wasFirstAttempt);
    notifyListeners();
  }

  void markRepeat() {
    if (_cards.isEmpty) return;
    final card = _cards.removeAt(_currentIndex);
    _repeatedCardIds.add(card.id);
    _cards.add(card);
    _repeatCount = _repeatCount + 1;
    _passedCount = _passedCount + 1;
    _isFlipped = false;
    if (_currentIndex >= _cards.length) {
      _currentIndex = 0;
    }
    final packageId = _cardPackageIds[card.id] ?? _package.id;
    progress?.markNeedsReview(packageId, card);
    notifyListeners();
  }
}
