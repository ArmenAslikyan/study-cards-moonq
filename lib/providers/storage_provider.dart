import 'package:flutter/foundation.dart';
import 'package:study_cards_moonq/domain/i_storage_repo.dart';
import 'package:study_cards_moonq/infrastructure/storage_repo.dart';
import 'package:study_cards_moonq/models/package.dart';

class StorageProvider extends ChangeNotifier implements IStorageRepo {
  StorageProvider([StorageRepo? repo]) : _repo = repo ?? StorageRepo();

  final StorageRepo _repo;

  bool get isLoaded => _repo.isLoaded;

  @override
  Map<String, Map<String, dynamic>> get progress => _repo.progress;

  @override
  Set<int> get addedPackageIds => _repo.addedPackageIds;

  @override
  Set<String> get studiedDates => _repo.studiedDates;

  @override
  int get streak => _repo.streak;

  @override
  Future<void> load() async {
    await _repo.load();
    notifyListeners();
  }

  @override
  Future<void> saveProgress(String key, Map<String, dynamic> value) async {
    await _repo.saveProgress(key, value);
    notifyListeners();
  }

  @override
  Future<void> removeProgress(String key) async {
    await _repo.removeProgress(key);
    notifyListeners();
  }

  @override
  Future<void> saveAddedPackages(Set<int> ids) async {
    await _repo.saveAddedPackages(ids);
    notifyListeners();
  }

  @override
  Future<void> recordStudyDate(String date) async {
    await _repo.recordStudyDate(date);
    notifyListeners();
  }

  @override
  Future<void> saveCustomPackages(List<Package> packages) async {
    await _repo.saveCustomPackages(packages);
    notifyListeners();
  }

  @override
  Future<List<Package>> loadCustomPackages() async {
    return _repo.loadCustomPackages();
  }
}
