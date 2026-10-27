import 'package:study_cards_moonq/models/package.dart';

abstract interface class IStorageRepo {
  Map<String, Map<String, dynamic>> get progress;
  Set<int> get addedPackageIds;
  Set<String> get studiedDates;
  int get streak;

  Future<void> load();
  Future<void> saveProgress(String key, Map<String, dynamic> value);
  Future<void> removeProgress(String key);
  Future<void> saveAddedPackages(Set<int> ids);
  Future<void> recordStudyDate(String date);
  Future<void> saveCustomPackages(List<Package> packages);
  Future<List<Package>> loadCustomPackages();
}

