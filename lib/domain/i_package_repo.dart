import 'package:study_cards_moonq/models/package.dart';

abstract interface class IPackageRepo {
  Future<List<Package>> getPackages();
  Future<void> addPackage(Package package);
  Future<void> deletePackage(int packageId);
}
