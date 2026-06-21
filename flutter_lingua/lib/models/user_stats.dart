class UserStats {
  final String username;
  final int totalXp;
  final int level;
  final int streakDays;
  final int vocabularyCount;
  final int conversationsCount;
  final String targetLanguage;

  const UserStats({
    required this.username,
    required this.totalXp,
    required this.level,
    required this.streakDays,
    required this.vocabularyCount,
    required this.conversationsCount,
    required this.targetLanguage,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    username: json['username'] ?? 'user',
    totalXp: json['total_xp'] ?? 0,
    level: json['level'] ?? 1,
    streakDays: json['streak_days'] ?? 0,
    vocabularyCount: json['vocabulary_count'] ?? 0,
    conversationsCount: json['conversations_count'] ?? 0,
    targetLanguage: json['target_language'] ?? 'es',
  );

  int get xpToNextLevel => 50 - (totalXp % 50);
  double get levelProgress => (totalXp % 50) / 50.0;
}
