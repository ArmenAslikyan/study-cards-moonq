import 'package:flutter/material.dart';
import 'package:study_cards_moonq/core/packages.dart' as default_catalog;
import 'package:study_cards_moonq/domain/i_package_repo.dart';
import 'package:study_cards_moonq/domain/i_storage_repo.dart';
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/models/package.dart';

class PackageProvider extends ChangeNotifier {
  PackageProvider(this._repo, this._storage) {
    loadPackages();
  }

  final IPackageRepo _repo;
  final IStorageRepo _storage;

  List<Package> _packages = [];
  List<Package> _customPackages = [];

  List<Package> get packages => _packages;
  List<Package> get customPackages => _customPackages;

  List<Package> get availablePackages {
    final list = <Package>[];
    list.addAll(default_catalog.packages);
    for (final customPkg in _customPackages) {
      final alreadyInCatalog = default_catalog.packages.any(
        (p) => p.id == customPkg.id,
      );
      if (!alreadyInCatalog) {
        list.add(customPkg);
      }
    }
    return list;
  }

  Future<void> addPackage(Package package) async {
    final isAlreadyAdded = _packages.any((p) => p.id == package.id);
    if (isAlreadyAdded) {
      return;
    }
    await _repo.addPackage(package);
    final updatedIds = Set<int>.from(_storage.addedPackageIds);
    updatedIds.add(package.id);
    await _storage.saveAddedPackages(updatedIds);
    _packages = await _repo.getPackages();
    notifyListeners();
  }

  Future<void> deletePackage(int packageId) async {
    await _repo.deletePackage(packageId);
    final updatedIds = _storage.addedPackageIds.where((id) => id != packageId).toSet();
    await _storage.saveAddedPackages(updatedIds);
    _packages = await _repo.getPackages();
    notifyListeners();
  }

  Future<Package> createCustomPackage({
    required String title,
    required List<Flashcards> flashcards,
    IconData iconData = Icons.style_outlined,
    Color iconBackground = const Color(0xFFC2185B),
  }) async {
    int newId = 100;
    while (_packages.any((p) => p.id == newId) || _customPackages.any((p) => p.id == newId)) {
      newId = newId + 1;
    }
    final newPackage = Package(
      id: newId,
      title: title,
      flashcards: flashcards,
      icon: Icon(iconData),
      iconColor: const Icon(Icons.circle, color: Colors.white),
      iconBackground: iconBackground,
    );
    _customPackages.add(newPackage);
    await _storage.saveCustomPackages(_customPackages);
    await addPackage(newPackage);
    return newPackage;
  }

  Future<void> loadPackages() async {
    _customPackages = await _storage.loadCustomPackages();
    for (final package in availablePackages) {
      final isSavedInPrefs = _storage.addedPackageIds.contains(package.id);
      final isAlreadyInList = _packages.any((p) => p.id == package.id);
      if (isSavedInPrefs && !isAlreadyInList) {
        await _repo.addPackage(package);
      }
    }
    _packages = await _repo.getPackages();
    notifyListeners();
  }
}
