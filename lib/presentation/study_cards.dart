import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_cards_moonq/models/package.dart';
import 'package:study_cards_moonq/presentation/new_package.dart';
import 'package:study_cards_moonq/presentation/review_screen.dart';
import 'package:study_cards_moonq/presentation/widgets/package_card.dart';
import 'package:study_cards_moonq/providers/package_provider.dart';
import 'package:study_cards_moonq/providers/progress_provider.dart';
import 'package:study_cards_moonq/providers/review_provider.dart';

class StudyCards extends StatelessWidget {
  const StudyCards({super.key});

  @override
  Widget build(BuildContext context) {
    final packages = context.select<PackageProvider, List<Package>>(
      (p) => p.packages,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Փաթեթներ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  _StreakBadge(),
                ],
              ),
              const SizedBox(height: 4),
              const _LearnedTodayText(),
              const SizedBox(height: 20),
              _ReviewQueueBanner(packages: packages),
              const SizedBox(height: 24),
              const Text(
                'Իմ փաթեթները',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 24),
              if (packages.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Դեռ փաթեթներ չկան',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: packages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _PackageItem(package: packages[index]),
                ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const NewPackage(),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFFC2185B),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: Color(0xFFC2185B)),
                    SizedBox(width: 8),
                    Text(
                      'Նոր փաթեթ',
                      style: TextStyle(
                        color: Color(0xFFC2185B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge();

  @override
  Widget build(BuildContext context) {
    final streak = context.select<ProgressProvider, int>((p) => p.streak);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8D7D7)),
      ),
      child: Row(
        children: [
          Text(
            '$streak օր',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFC2185B),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'շարունակ',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LearnedTodayText extends StatelessWidget {
  const _LearnedTodayText();

  @override
  Widget build(BuildContext context) {
    final learnedToday = context.select<ProgressProvider, int>(
      (p) => p.learnedToday,
    );
    return Text(
      'Այսօր սովորել ես $learnedToday քարտ',
      style: const TextStyle(color: Colors.grey, fontSize: 14),
    );
  }
}

class _ReviewQueueBanner extends StatelessWidget {
  const _ReviewQueueBanner({required this.packages});

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

class _PackageItem extends StatelessWidget {
  const _PackageItem({required this.package});

  final Package package;

  @override
  Widget build(BuildContext context) {
    final learnedCount = context.select<ProgressProvider, int>(
      (p) => p.getLearnedCount(package),
    );

    return PackageCard(
      package: package,
      learnedCount: learnedCount,
      onTap: () {
        context.read<ReviewProvider>().selectPackage(package);
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ReviewScreen(),
          ),
        );
      },
    );
  }
}
