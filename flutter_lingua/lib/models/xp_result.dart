class XpResult {
  final int xpEarned;
  final int totalXp;
  final int level;
  final bool leveledUp;
  final int streakDays;

  const XpResult({
    required this.xpEarned,
    required this.totalXp,
    required this.level,
    required this.leveledUp,
    required this.streakDays,
  });

  factory XpResult.fromJson(Map<String, dynamic> json) => XpResult(
    xpEarned: json['xp_earned'] ?? 0,
    totalXp: json['total_xp'] ?? 0,
    level: json['level'] ?? 1,
    leveledUp: json['leveled_up'] ?? false,
    streakDays: json['streak_days'] ?? 0,
  );

  int get xpToNextLevel => 50 - (totalXp % 50);
  double get levelProgress => (totalXp % 50) / 50.0;
}
