import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_cards_moonq/models/package.dart';
import 'package:study_cards_moonq/presentation/review_screen.dart';
import 'package:study_cards_moonq/providers/progress_provider.dart';
import 'package:study_cards_moonq/providers/review_provider.dart';

class ReviewQueueBanner extends StatelessWidget {
  const ReviewQueueBanner({super.key, required this.packages});

  final List<Package> packages;

  @override
  Widget build(BuildContext context) {
    final dueCount = context.select<ProgressProvider, int>(
      (p) => p.getDueCount(packages),
    );
    final hasUnstudiedCards = context.select<ProgressProvider, bool>(
      (p) => p.hasUnstudiedCards(packages),
    );
    final hasCardsToReview = dueCount > 0;

    if (hasCardsToReview) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFC2185B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ԿՐԿՆՈՒԹՅԱՆ ՀԵՐԹ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$dueCount քարտ սպասում է',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${packages.length} փաթեթ · ~${(dueCount * 0.4).ceil()} րոպե',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  color: Color(0xFFC2185B),
                ),
                onPressed: () {
                  context.read<ReviewProvider>().startDueReview(packages);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ReviewScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF287A5B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  packages.isEmpty ? 'ԿՐԿՆՈՒԹՅԱՆ ՀԵՐԹ' : 'ՀՐԱՇԱԼԻ ԱՇԽԱՏԱՆՔ',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  packages.isEmpty || hasUnstudiedCards
                      ? 'Կրկնելու քարտեր չկան'
                      : 'Դու յուրացրել ես բոլոր քարտերը',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  packages.isEmpty
                      ? 'Ավելացրու փաթեթ՝ սովորել սկսելու համար։'
                      : hasUnstudiedCards
                          ? 'Սեղմիր փաթեթը՝ սովորելը սկսելու համար։'
                          : 'Այս պահին կրկնելու ոչինչ չկա։',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF287A5B),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

