import 'package:flutter/material.dart';
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/presentation/widgets/review_card_panel.dart';

class ReviewCardFront extends StatelessWidget {
  const ReviewCardFront({super.key, required this.card});
  final Flashcards card;
  @override Widget build(BuildContext context) => ReviewCardPanel(color: Colors.white, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('ՀԱՅԵՐԵՆ ԿՈՂՄ', style: TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 1.2)), const SizedBox(height: 16), Text(card.armenianWord, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.bold)), const SizedBox(height: 15), const Text('Սեղմիր քարտը՝ թարգմանությունը\nտեսնելու համար', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)), const Spacer(), const Text('↻  Շրջել', style: TextStyle(color: Color(0xFFD81B60), fontWeight: FontWeight.w600))]));
}
