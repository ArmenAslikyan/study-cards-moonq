import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_cards_moonq/infrastructure/package_repo.dart';
import 'package:study_cards_moonq/providers/package_provider.dart';
import 'package:study_cards_moonq/study_cards_moonq.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PackageProvider(PackageRepo()),
        ),
      ],
      child: StudyCardsMoonq(),
    ),
  );
}
