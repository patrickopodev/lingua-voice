import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  List<Lesson> _lessons = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final data = await api.getLessons();
      if (mounted) {
        setState(() => _lessons = data.map((e) => Lesson.fromJson(e)).toList());
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
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
            Text('Failed to load lessons', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            FilledButton.tonal(onPressed: _loadLessons, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_lessons.isEmpty) return const Center(child: Text('No lessons available'));

    return RefreshIndicator(
      onRefresh: _loadLessons,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _lessons.length,
        itemBuilder: (context, index) {
          final lesson = _lessons[index];
          return _LessonCard(
            lesson: lesson,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(lesson: lesson),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const _LessonCard({required this.lesson, required this.onTap});

  IconData _scenarioIcon() {
    switch (lesson.scenario) {
      case 'restaurant': return Icons.restaurant;
      case 'airport': return Icons.flight;
      case 'shopping': return Icons.shopping_bag;
      case 'hotel': return Icons.hotel;
      case 'interview': return Icons.work;
      case 'doctor': return Icons.local_hospital;
      default: return Icons.chat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_scenarioIcon(), color: Theme.of(context).primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(lesson.description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...List.generate(lesson.difficulty, (_) => const Icon(Icons.circle, size: 8, color: Colors.amber)),
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                        Text(' ${lesson.xpReward} XP', style: TextStyle(fontSize: 12, color: Colors.amber.shade800, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
