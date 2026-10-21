import 'package:flutter/material.dart';
import 'package:study_cards_moonq/providers/review_provider.dart';

class ReviewFinished extends StatelessWidget {
  const ReviewFinished({super.key, required this.review});
  final ReviewProvider review;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 72, color: Color(0xFF2E7D32)),
            const SizedBox(height: 18),
            const Text('Պարապմունքի ամփոփում', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text('Անցել ես ընդհանուր՝ ${review.totalCount} քարտ'),
            const SizedBox(height: 35),
            SizedBox(
              width: 220,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await review.restartCurrentSession();
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Նորից սկսել', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD81B60),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 220,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Գլխավոր էջ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD81B60),
                  side: const BorderSide(color: Color(0xFFD81B60)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      );
}
