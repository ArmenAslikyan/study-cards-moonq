import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:study_cards_moonq/core/packages.dart' as catalog;
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/models/package.dart';
import 'package:study_cards_moonq/providers/progress_provider.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider({Package? package, ProgressProvider? progress})
      : _package = package ?? catalog.packages.first,
        _progress = progress {
    restart();
  }

  Package _package;
  final ProgressProvider? _progress;
  late List<Flashcards> _cards;
  List<Flashcards> _sessionCards = [];
  bool _isMixedReview = false;
  final Map<String, int> _cardPackageIds = {};
  int _sessionTotalCount = 0;
  int _currentIndex = 0;
  int _knownCount = 0;
  int _repeatCount = 0;
  int _passedCount = 0;

  Package get package => _package;
  List<Flashcards> get cards => List.unmodifiable(_cards);
  Flashcards? get currentCard => _cards.isEmpty ? null : _cards[_currentIndex];
  int get totalCount => _sessionTotalCount;
  int get remainingCount => _cards.length;
  int get currentProgress => _passedCount.clamp(0, totalCount);
  int get knownCount => _knownCount;
  int get repeatCount => _repeatCount;
  bool get isFinished => _cards.isEmpty;

  void selectPackage(Package package) {
    _package = package;
    restart();
  }

  void startDueReview(List<Package> packages) {
    _isMixedReview = true;
    _cards = [];
    _cardPackageIds.clear();
    for (final package in packages) {
      for (final card in package.flashcards) {
        if (_progress?.needsReview(package.id, card) ?? false) {
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
    notifyListeners();
  }

  void restart() {
    _isMixedReview = false;
    _cards = _package.flashcards
        .where((card) => !(_progress?.isKnown(_package.id, card) ?? false))
        .toList();
    _cardPackageIds
      ..clear()
      ..addEntries(_cards.map((card) => MapEntry(card.id, _package.id)));
    _sessionTotalCount = _cards.length;
    _sessionCards = List.of(_cards);
    _currentIndex = 0;
    _knownCount = 0;
    _repeatCount = 0;
    _passedCount = 0;
    notifyListeners();
  }

  void shuffle() {
    _cards.shuffle(Random());
    _currentIndex = 0;
    notifyListeners();
  }

  Future<void> restartCurrentSession() async {
    final cardsToReset = _isMixedReview
        ? _sessionCards
        : _package.flashcards;
    for (final card in cardsToReset) {
      await _progress?.resetCard(
        _isMixedReview
            ? (_cardPackageIds[card.id] ?? _package.id)
            : _package.id,
        card,
      );
    }
    // Always restore the queue captured when this session started. Do not
    // rebuild it from ProgressProvider while resetting the session.
    _cards = _isMixedReview
        ? List<Flashcards>.of(_sessionCards)
        : List<Flashcards>.of(_package.flashcards);
    _sessionTotalCount = _cards.length;
    _currentIndex = 0;
    _knownCount = 0;
    _repeatCount = 0;
    _passedCount = 0;
    notifyListeners();
  }

  void markKnown() {
    if (_cards.isEmpty) return;
    final card = _cards[_currentIndex];
    _cards.removeAt(_currentIndex);
    _knownCount++;
    _passedCount++;
    if (_cards.isNotEmpty && _currentIndex >= _cards.length) _currentIndex = 0;
    _progress?.markKnown(
      _cardPackageIds[card.id] ?? _package.id,
      card,
      firstAttempt: _repeatCount == 0,
    );
    notifyListeners();
  }

  void markRepeat() {
    if (_cards.isEmpty) return;
    final card = _cards.removeAt(_currentIndex);
    _cards.add(card);
    _repeatCount++;
    _passedCount++;
    if (_currentIndex >= _cards.length) _currentIndex = 0;
    _progress?.markNeedsReview(_cardPackageIds[card.id] ?? _package.id, card);
    notifyListeners();
  }
}
