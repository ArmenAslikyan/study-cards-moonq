import 'package:flutter/material.dart';
import 'package:study_cards_moonq/core/packages.dart' as package_catalog;
import 'package:study_cards_moonq/domain/i_package_repo.dart';
import 'package:study_cards_moonq/models/package.dart';

class PackageProvider extends ChangeNotifier {
  PackageProvider(this._repo) {
    loadPackages();
  }

  final IPackageRepo _repo;
  List<Package> _packages = [];

  List<Package> get packages => _packages;
  List<Package> get availablePackages => package_catalog.packages;

  Future<void> addPackage(Package package) async {
    if (_packages.any((existingPackage) => existingPackage.id == package.id)) {
      return;
    }

    await _repo.addPackage(package);
    _packages = await _repo.getPackages();
    notifyListeners();
  }

  Future<void> deletePackage(int packageId) async {
    await _repo.deletePackage(packageId);
    _packages = await _repo.getPackages();
    notifyListeners();
  }

  Future<void> loadPackages() async {
    _packages = await _repo.getPackages();
    notifyListeners();
  }
}
