import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_cards_moonq/domain/i_storage_repo.dart';
import 'package:study_cards_moonq/infrastructure/package_repo.dart';
import 'package:study_cards_moonq/infrastructure/storage_repo.dart';
import 'package:study_cards_moonq/providers/package_provider.dart';
import 'package:study_cards_moonq/providers/progress_provider.dart';
import 'package:study_cards_moonq/providers/review_provider.dart';
import 'package:study_cards_moonq/providers/storage_provider.dart';
import 'package:study_cards_moonq/study_cards_moonq.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageRepo = StorageRepo();
  await storageRepo.load();
  runApp(
    MultiProvider(
      providers: [
        Provider<IStorageRepo>.value(value: storageRepo),
        Provider<StorageRepo>.value(value: storageRepo),
        ChangeNotifierProvider(create: (_) => StorageProvider(storageRepo)),
        ChangeNotifierProvider(create: (_) => ProgressProvider(storageRepo)),
        ChangeNotifierProvider(
          create: (_) => PackageProvider(
            PackageRepo(),
            storageRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ReviewProvider(
            progress: context.read<ProgressProvider>(),
          ),
        ),
      ],
      child: const StudyCardsMoonq(),
    ),
  );
}
