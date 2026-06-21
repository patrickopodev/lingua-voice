class VocabWord {
  final String word;
  final String translation;
  final String language;
  final String? context;
  final int masteryLevel;
  final String? lastReviewed;

  const VocabWord({
    required this.word,
    required this.translation,
    this.language = 'es',
    this.context,
    this.masteryLevel = 1,
    this.lastReviewed,
  });

  factory VocabWord.fromJson(Map<String, dynamic> json) => VocabWord(
    word: json['word'] ?? '',
    translation: json['translation'] ?? '',
    language: json['language'] ?? 'es',
    context: json['context'],
    masteryLevel: json['mastery_level'] ?? 1,
    lastReviewed: json['last_reviewed'],
  );
}
