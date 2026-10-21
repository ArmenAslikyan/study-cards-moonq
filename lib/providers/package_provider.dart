import 'package:flutter/material.dart';
import 'package:study_cards_moonq/core/packages.dart' as package_catalog;
import 'package:study_cards_moonq/domain/i_package_repo.dart';
import 'package:study_cards_moonq/models/package.dart';
import 'package:study_cards_moonq/providers/storage_provider.dart';

class PackageProvider extends ChangeNotifier {
  PackageProvider(this._repo, this._storage) {
    loadPackages();
  }

  final IPackageRepo _repo;
  final StorageProvider _storage;
  List<Package> _packages = [];

  List<Package> get packages => _packages;
  List<Package> get availablePackages => package_catalog.packages;

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

  Future<void> loadPackages() async {
    for (final package in availablePackages) {
      if (_storage.addedPackageIds.contains(package.id)) {
        await _repo.addPackage(package);
      }
    }
    _packages = await _repo.getPackages();
    notifyListeners();
  }
}
