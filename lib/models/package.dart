import 'package:flutter/material.dart';
import 'package:study_cards_moonq/models/flashcards.dart';

class Package {
  final String title;
  final List<Flashcards> flashcards = [];
  final int cardNumber;
  final Icon icon;
  final Icon iconColor;
  final Color iconBackground;
  int learnt = 0;
  double get donePrecentage => cardNumber == 0 ? 0 : (learnt / cardNumber) * 100;
  Package({
    required this.title,
    required this.cardNumber,
    required this.icon,
    required this.iconColor,
    required this.iconBackground
  });
}