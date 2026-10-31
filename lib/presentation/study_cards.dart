import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_cards_moonq/models/package.dart';
import 'package:study_cards_moonq/presentation/new_package.dart';
import 'package:study_cards_moonq/presentation/review_screen.dart';
import 'package:study_cards_moonq/presentation/widgets/package_card.dart';
import 'package:study_cards_moonq/presentation/widgets/review_queue_banner.dart';
import 'package:study_cards_moonq/presentation/widgets/streak_badge.dart';
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
    final learnedToday = context.select<ProgressProvider, int>(
      (p) => p.learnedToday,
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
                  StreakBadge(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Այսօր սովորել ես $learnedToday քարտ',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ReviewQueueBanner(packages: packages),
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
                  itemBuilder: (context, index) {
                    final package = packages[index];
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
                  },
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
