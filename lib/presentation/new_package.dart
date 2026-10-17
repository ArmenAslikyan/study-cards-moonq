import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_cards_moonq/models/package.dart';
import 'package:study_cards_moonq/providers/package_provider.dart';

class NewPackage extends StatelessWidget {
  const NewPackage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackageProvider>();
    final availablePackages = provider.availablePackages;
    final addedPackageIds = provider.packages
        .map((package) => package.id)
        .toSet();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F7),
        title: const Text('Նոր փաթեթ'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: availablePackages.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final package = availablePackages[index];
          final isAdded = addedPackageIds.contains(package.id);

          return _PackageOption(
            package: package,
            isAdded: isAdded,
            onAdd: () => context.read<PackageProvider>().addPackage(package),
            onDelete: () =>
                context.read<PackageProvider>().deletePackage(package.id),
          );
        },
      ),
    );
  }
}

class _PackageOption extends StatelessWidget {
  const _PackageOption({
    required this.package,
    required this.isAdded,
    required this.onAdd,
    required this.onDelete,
  });

  final Package package;
  final bool isAdded;
  final Future<void> Function() onAdd;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: package.iconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            package.icon.icon,
            color: package.iconColor.color ?? Colors.white,
          ),
        ),
        title: Text(
          package.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${package.cardNumber} քարտ'),
        trailing: IconButton(
          tooltip: isAdded ? 'Հեռացնել փաթեթը' : 'Ավելացնել փաթեթը',
          onPressed: () => isAdded ? onDelete() : onAdd(),
          icon: Icon(isAdded ? Icons.delete_outline : Icons.add_circle_outline),
          color: isAdded ? const Color(0xFFB13C4A) : const Color(0xFFC2185B),
        ),
      ),
    );
  }
}
