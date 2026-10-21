import 'package:flutter/material.dart';
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/presentation/widgets/review_card_panel.dart';

class ReviewCardBack extends StatelessWidget {
  const ReviewCardBack({super.key, required this.card});
  final Flashcards card;
  @override Widget build(BuildContext context) => ReviewCardPanel(color: const Color(0xFF231F20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('ԱՆԳԼԵՐԵՆ ԿՈՂՄ', style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2)), const SizedBox(height: 10), Text(card.englishTranslation, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)), Text(card.pronunciation, style: const TextStyle(color: Colors.white60)), const Divider(color: Colors.white24, height: 28), const Text('ՕՐԻՆԱԿ', style: TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1.1)), const SizedBox(height: 6), Text(card.exampleSentence, style: const TextStyle(color: Colors.white, fontSize: 14)), const SizedBox(height: 4), Text(card.exampleSentenceArmenian, style: const TextStyle(color: Colors.white60, fontSize: 13))]));
}
