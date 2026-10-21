import 'package:flutter/material.dart';

class ReviewStat extends StatelessWidget {
  const ReviewStat(this.value, this.label, this.color, {super.key});
  final String value, label; final Color color;
  @override Widget build(BuildContext context) => Column(children: [Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))]);
}
