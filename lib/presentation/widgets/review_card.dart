import 'dart:math';
import 'package:flutter/material.dart';
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/presentation/widgets/review_card_back.dart';
import 'package:study_cards_moonq/presentation/widgets/review_card_front.dart';

class ReviewCard extends StatefulWidget {
  const ReviewCard({super.key, required this.card});
  final Flashcards card;
  @override State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
  bool _flipped = false;
  @override void dispose() { _controller.dispose(); super.dispose(); }
  void _toggle() { setState(() => _flipped = !_flipped); _flipped ? _controller.forward() : _controller.reverse(); }
  @override Widget build(BuildContext context) => GestureDetector(onTap: _toggle, child: AnimatedBuilder(animation: _controller, builder: (context, _) {
    final angle = _controller.value * pi;
    return Transform(alignment: Alignment.center, transform: Matrix4.identity()..setEntry(3, 2, .001)..rotateY(angle), child: angle >= pi / 2 ? Transform(alignment: Alignment.center, transform: Matrix4.rotationY(pi), child: ReviewCardBack(card: widget.card)) : ReviewCardFront(card: widget.card));
  }));
}
