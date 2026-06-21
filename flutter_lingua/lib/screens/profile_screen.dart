import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_stats.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final data = await api.getStats('default');
      if (mounted) setState(() => _stats = UserStats.fromJson(data));
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
            Text('Failed to load stats', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            FilledButton.tonal(onPressed: _loadStats, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_stats == null) return const Center(child: Text('No stats available'));

    final s = _stats!;
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              s.username[0].toUpperCase(),
              style: const TextStyle(fontSize: 36, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(s.username, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _StatCard(
            icon: Icons.star,
            label: 'Level',
            value: '${s.level}',
            subtitle: '${s.totalXp} total XP',
          ),
          _StatCard(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '${s.streakDays} days',
          ),
          _StatCard(
            icon: Icons.menu_book,
            label: 'Vocabulary',
            value: '${s.vocabularyCount} words',
          ),
          _StatCard(
            icon: Icons.chat,
            label: 'Conversations',
            value: '${s.conversationsCount}',
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: s.levelProgress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: Colors.amber.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${s.totalXp} / ${((s.totalXp ~/ 50) + 1) * 50} XP to next level',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        title: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle ?? label),
      ),
    );
  }
}
