import 'dart:math';
import 'package:flutter/material.dart';
import 'package:study_cards_moonq/models/flashcards.dart';

class ReviewCard extends StatefulWidget {
  const ReviewCard({super.key, required this.card, this.onFlip});

  final Flashcards card;
  final VoidCallback? onFlip;

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
  bool _flipped = false;

  @override
  void didUpdateWidget(ReviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      _flipped = false;
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _flipped = !_flipped);
    _flipped ? _controller.forward() : _controller.reverse();
    widget.onFlip?.call();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _toggle,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final angle = _controller.value * pi;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..setEntry(3, 2, .001)..rotateY(angle),
          child: angle >= pi / 2
              ? Transform(alignment: Alignment.center, transform: Matrix4.rotationY(pi), child: _CardBack(card: widget.card))
              : _CardFront(card: widget.card),
        );
      },
    ),
  );
}

class _CardPanel extends StatelessWidget {
  const _CardPanel({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: MediaQuery.sizeOf(context).width * .84,
    height: 300,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [BoxShadow(blurRadius: 15, offset: Offset(0, 8), color: Color(0x18000000))],
    ),
    child: child,
  );
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.card});

  final Flashcards card;

  @override
  Widget build(BuildContext context) => _CardPanel(
    color: Colors.white,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('ՀԱՅԵՐԵՆ ԿՈՂՄ', style: TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        Text(card.armenianWord, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        const Text('Սեղմիր քարտը՝ թարգմանությունը\nտեսնելու համար', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const Spacer(),
        const Text('↻  Շրջել', style: TextStyle(color: Color(0xFFD81B60), fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.card});

  final Flashcards card;

  @override
  Widget build(BuildContext context) => _CardPanel(
    color: const Color(0xFF231F20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ԱՆԳԼԵՐԵՆ ԿՈՂՄ', style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        Text(card.englishTranslation, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(card.pronunciation, style: const TextStyle(color: Colors.white60)),
        const Divider(color: Colors.white24, height: 28),
        const Text('ՕՐԻՆԱԿ', style: TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1.1)),
        const SizedBox(height: 6),
        Text(card.exampleSentence, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 4),
        Text(card.exampleSentenceArmenian, style: const TextStyle(color: Colors.white60, fontSize: 13)),
      ],
    ),
  );
}
