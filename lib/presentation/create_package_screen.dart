import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_cards_moonq/models/flashcards.dart';
import 'package:study_cards_moonq/providers/package_provider.dart';

class CreatePackageScreen extends StatefulWidget {
  const CreatePackageScreen({super.key});

  @override
  State<CreatePackageScreen> createState() => _CreatePackageScreenState();
}

class _CardInputData {
  final TextEditingController armenianWordController = TextEditingController();
  final TextEditingController englishTranslationController =
      TextEditingController();
  final TextEditingController pronunciationController =
      TextEditingController();
  final TextEditingController exampleSentenceController =
      TextEditingController();
  final TextEditingController exampleSentenceArmenianController =
      TextEditingController();

  void dispose() {
    armenianWordController.dispose();
    englishTranslationController.dispose();
    pronunciationController.dispose();
    exampleSentenceController.dispose();
    exampleSentenceArmenianController.dispose();
  }
}

class _CreatePackageScreenState extends State<CreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<_CardInputData> _cards = [_CardInputData()];

  @override
  void dispose() {
    _titleController.dispose();
    for (final card in _cards) {
      card.dispose();
    }
    super.dispose();
  }

  void _addCard() {
    setState(() {
      _cards.add(_CardInputData());
    });
  }

  void _removeCard(int index) {
    if (_cards.length <= 1) return;
    setState(() {
      final removed = _cards.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _savePackage() async {
    if (!_formKey.currentState!.validate()) return;

    final flashcards = _cards.map((c) {
      return Flashcards(
        armenianWord: c.armenianWordController.text.trim(),
        pronunciation: c.pronunciationController.text.trim().isNotEmpty
            ? c.pronunciationController.text.trim()
            : '/${c.englishTranslationController.text.trim().toLowerCase()}/',
        englishTranslation: c.englishTranslationController.text.trim(),
        exampleSentence: c.exampleSentenceController.text.trim(),
        exampleSentenceArmenian:
            c.exampleSentenceArmenianController.text.trim(),
      );
    }).toList();

    await context.read<PackageProvider>().createCustomPackage(
          title: _titleController.text.trim(),
          flashcards: flashcards,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Փաթեթը հաջողությամբ ստեղծվեց'),
          backgroundColor: Color(0xFF287A5B),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Ստեղծել սեփական փաթեթ',
          style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8D7D7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Փաթեթի վերնագիր',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Օրինակ՝ Իմ նոր բառերը',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Մուտքագրեք փաթեթի վերնագիրը';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Քարտեր',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addCard,
                  icon: const Icon(Icons.add, color: Color(0xFFC2185B)),
                  label: const Text(
                    'Ավելացնել քարտ',
                    style: TextStyle(
                      color: Color(0xFFC2185B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < _cards.length; i++)
              _buildCardEditor(i),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePackage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC2185B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Պահպանել փաթեթը',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCardEditor(int index) {
    final card = _cards[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D7D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Քարտ ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFFC2185B),
                ),
              ),
              if (_cards.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                  onPressed: () => _removeCard(index),
                  tooltip: 'Հեռացնել քարտը',
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: card.armenianWordController,
            decoration: InputDecoration(
              labelText: 'Հարց / Հայերեն բառ *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Մուտքագրեք հարցը / հայերեն բառը';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: card.englishTranslationController,
            decoration: InputDecoration(
              labelText: 'Պատասխան / Անգլերեն թարգմանություն *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Մուտքագրեք պատասխանը / անգլերեն թարգմանությունը';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: card.pronunciationController,
            decoration: InputDecoration(
              labelText: 'Արտասանություն (կամընտիր)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: card.exampleSentenceController,
            decoration: InputDecoration(
              labelText: 'Օրինակ նախադասություն (կամընտիր)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: card.exampleSentenceArmenianController,
            decoration: InputDecoration(
              labelText: 'Օրինակի հայերեն թարգմանություն (կամընտիր)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

