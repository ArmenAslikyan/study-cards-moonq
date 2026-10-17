import 'package:flutter/material.dart';
import 'package:study_cards_moonq/presentation/study_cards.dart';

class StudyCardsMoonq extends StatelessWidget {
  const StudyCardsMoonq({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Cards',
      home: StudyCards(),
    );
  }
}