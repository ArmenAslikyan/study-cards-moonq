import 'package:flutter/material.dart';

class ReviewCardPanel extends StatelessWidget {
  const ReviewCardPanel({super.key, required this.color, required this.child});
  final Color color;
  final Widget child;
  @override Widget build(BuildContext context) => Container(width: MediaQuery.sizeOf(context).width * .84, height: 300, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(blurRadius: 15, offset: Offset(0, 8), color: Color(0x18000000))]), child: child);
}
