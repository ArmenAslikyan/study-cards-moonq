import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_cards_moonq/infrastructure/package_repo.dart';
import 'package:study_cards_moonq/providers/package_provider.dart';
import 'package:study_cards_moonq/providers/review_provider.dart';
import 'package:study_cards_moonq/providers/progress_provider.dart';
import 'package:study_cards_moonq/providers/storage_provider.dart';
import 'package:study_cards_moonq/study_cards_moonq.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageProvider();
  await storage.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: storage),
        ChangeNotifierProvider(create: (_) => ProgressProvider(storage)),
        ChangeNotifierProvider(
          create: (context) => PackageProvider(
            PackageRepo(),
            context.read<StorageProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ReviewProvider(
            progress: context.read<ProgressProvider>(),
          ),
        ),
      ],
      child: StudyCardsMoonq(),
    ),
  );
}
