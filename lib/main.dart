import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_cards_moonq/infrastructure/package_repo.dart';
import 'package:study_cards_moonq/infrastructure/storage_repo.dart';
import 'package:study_cards_moonq/providers/package_provider.dart';
import 'package:study_cards_moonq/providers/progress_provider.dart';
import 'package:study_cards_moonq/providers/review_provider.dart';
import 'package:study_cards_moonq/providers/storage_provider.dart';
import 'package:study_cards_moonq/study_cards_moonq.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageRepo();
  await storage.load();
  final progress = ProgressProvider(storage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StorageProvider(storage)),
        ChangeNotifierProvider(create: (_) => progress),
        ChangeNotifierProvider(create: (_) => PackageProvider(PackageRepo(), storage)),
        ChangeNotifierProvider(create: (_) => ReviewProvider(progress: progress)),
      ],
      child: const StudyCardsMoonq(),
    ),
  );
}
