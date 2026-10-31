import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_cards_moonq/providers/progress_provider.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key});

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

