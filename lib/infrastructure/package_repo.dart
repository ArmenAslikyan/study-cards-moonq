import 'package:study_cards_moonq/domain/i_package_repo.dart';
import 'package:study_cards_moonq/models/package.dart';

class PackageRepo implements IPackageRepo {
  final List<Package> _packages = [];

  @override
  Future<List<Package>> getPackages() async {
    return List.of(_packages);
  }

  @override
  Future<void> addPackage(Package package) async {
    _packages.add(package);
  }

  @override
  Future<void> deletePackage(int packageId) async {
    _packages.removeWhere((p) => p.id == packageId);
  }
}
