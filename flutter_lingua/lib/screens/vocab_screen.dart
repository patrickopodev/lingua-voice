import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vocab_word.dart';
import '../services/api_service.dart';

class VocabScreen extends StatefulWidget {
  const VocabScreen({super.key});

  @override
  State<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends State<VocabScreen> {
  List<VocabWord> _words = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVocab();
  }

  Future<void> _loadVocab() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final data = await api.getVocabulary('default');
      if (mounted) {
        final list = (data['words'] as List?) ?? [];
        setState(() => _words = list.map((e) => VocabWord.fromJson(e)).toList());
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  Color _masteryColor(int level) {
    switch (level) {
      case 1: return Colors.red.shade300;
      case 2: return Colors.orange.shade300;
      case 3: return Colors.amber.shade400;
      case 4: return Colors.lightGreen.shade400;
      case 5: return Colors.green.shade500;
      default: return Colors.grey;
    }
  }

  String _masteryLabel(int level) {
    switch (level) {
      case 1: return 'New';
      case 2: return 'Learning';
      case 3: return 'Familiar';
      case 4: return 'Practiced';
      case 5: return 'Mastered';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Failed to load vocabulary', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            FilledButton.tonal(onPressed: _loadVocab, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_words.isEmpty) return const Center(child: Text('No words yet. Start a conversation!'));

    return RefreshIndicator(
      onRefresh: _loadVocab,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _words.length,
        itemBuilder: (context, index) {
          final w = _words[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _masteryColor(w.masteryLevel).withOpacity(0.2),
                child: Text(w.word[0].toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: _masteryColor(w.masteryLevel))),
              ),
              title: Text(w.word, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(w.translation),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _masteryColor(w.masteryLevel).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _masteryLabel(w.masteryLevel),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _masteryColor(w.masteryLevel)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
