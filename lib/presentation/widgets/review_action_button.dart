import 'package:flutter/material.dart';

class ReviewActionButton extends StatelessWidget {
  const ReviewActionButton({super.key, required this.label, required this.icon, required this.onTap, required this.color, required this.background});
  final String label; final IconData icon; final VoidCallback onTap; final Color color, background;
  @override Widget build(BuildContext context) => ElevatedButton.icon(onPressed: onTap, icon: Icon(icon, color: color), label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: background, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))));
}
