import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_cards_moonq/presentation/widgets/review_action_button.dart';
import 'package:study_cards_moonq/presentation/widgets/review_card.dart';
import 'package:study_cards_moonq/presentation/widgets/review_finished.dart';
import 'package:study_cards_moonq/presentation/widgets/review_stat.dart';
import 'package:study_cards_moonq/providers/review_provider.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final review = context.watch<ReviewProvider>();
    return Scaffold(backgroundColor: const Color(0xFFFDF7F7), body: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: review.isFinished ? ReviewFinished(review: review) : Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, size: 20)),
          Expanded(
            child: Column(
              children: [
                Text(
                  review.package.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Փաթեթի կրկնություն',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(onPressed: review.shuffle, icon: const Icon(Icons.shuffle)),
        ]), const SizedBox(height: 15),
        Row(children: [Expanded(child: LinearProgressIndicator(value: review.totalCount == 0 ? 0 : review.currentProgress / review.totalCount, minHeight: 8, borderRadius: BorderRadius.circular(10), color: const Color(0xFFD81B60), backgroundColor: const Color(0xFFE8E0E0))), const SizedBox(width: 12), Text('${review.currentProgress}/${review.totalCount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))]),
        const SizedBox(height: 15), Expanded(child: Center(child: ReviewCard(card: review.currentCard!))),
        Row(children: [Expanded(child: ReviewActionButton(label: 'Կրկնել', icon: Icons.rotate_right, onTap: review.markRepeat, color: const Color(0xFFD81B60), background: const Color(0xFFFDE8E8))), const SizedBox(width: 15), Expanded(child: ReviewActionButton(label: 'Գիտեմ', icon: Icons.check, onTap: review.markKnown, color: Colors.white, background: const Color(0xFF2E7D32)))]),
        const SizedBox(height: 25), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ReviewStat('${review.knownCount}', 'Գիտեմ', Colors.green), ReviewStat('${review.repeatCount}', 'Կրկնել', Colors.red), ReviewStat('${review.remainingCount}', 'Մնացած', Colors.black87)]), const SizedBox(height: 10),
      ]),
    )));
  }
}
