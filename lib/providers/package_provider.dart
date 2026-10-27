import 'package:flutter/material.dart';
import 'package:study_cards_moonq/core/packages.dart' as package_catalog;
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
  List<Package> get availablePackages => [
        ...package_catalog.packages,
        ..._customPackages.where(
          (cp) => !package_catalog.packages.any((p) => p.id == cp.id),
        ),
      ];
  List<Package> get customPackages => List.unmodifiable(_customPackages);

  Future<void> addPackage(Package package) async {
    if (_packages.any((existingPackage) => existingPackage.id == package.id)) {
      return;
    }

    await _repo.addPackage(package);
    await _storage.saveAddedPackages({..._storage.addedPackageIds, package.id});
    _packages = await _repo.getPackages();
    notifyListeners();
  }

  Future<void> deletePackage(int packageId) async {
    await _repo.deletePackage(packageId);
    await _storage.saveAddedPackages(
      _storage.addedPackageIds.where((id) => id != packageId).toSet(),
    );
    _packages = await _repo.getPackages();
    notifyListeners();
  }

  Future<Package> createCustomPackage({
    required String title,
    required List<Flashcards> flashcards,
    IconData iconData = Icons.style_outlined,
    Color iconBackground = const Color(0xFFC2185B),
  }) async {
    final allIds = <int>{
      ...package_catalog.packages.map((p) => p.id),
      ..._customPackages.map((p) => p.id),
      ..._packages.map((p) => p.id),
    };
    var newId = 100;
    while (allIds.contains(newId)) {
      newId++;
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

  Future<void> removeCustomPackage(int packageId) async {
    _customPackages.removeWhere((p) => p.id == packageId);
    await _storage.saveCustomPackages(_customPackages);
    await deletePackage(packageId);
  }

  Future<void> loadPackages() async {
    _customPackages = await _storage.loadCustomPackages();
    final all = availablePackages;
    for (final package in all) {
      if (_storage.addedPackageIds.contains(package.id)) {
        if (!_packages.any((p) => p.id == package.id)) {
          await _repo.addPackage(package);
        }
      }
    }
    _packages = await _repo.getPackages();
    notifyListeners();
  }
}
