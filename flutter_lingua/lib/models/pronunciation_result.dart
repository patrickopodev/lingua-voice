class PhonemeScore {
  final String phoneme;
  final double score;
  final bool isMispronounced;

  PhonemeScore({
    required this.phoneme,
    required this.score,
    required this.isMispronounced,
  });

  factory PhonemeScore.fromJson(Map<String, dynamic> json) => PhonemeScore(
        phoneme: json['phoneme'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0,
        isMispronounced: json['is_mispronounced'] as bool? ?? false,
      );
}

class WordScore {
  final String word;
  final double score;
  final bool isMispronounced;

  WordScore({
    required this.word,
    required this.score,
    required this.isMispronounced,
  });

  factory WordScore.fromJson(Map<String, dynamic> json) => WordScore(
        word: json['word'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0,
        isMispronounced: json['is_mispronounced'] as bool? ?? false,
      );
}

class PronunciationResult {
  final double overallScore;
  final double fluency;
  final List<WordScore> wordScores;
  final List<PhonemeScore> phonemeScores;

  PronunciationResult({
    required this.overallScore,
    required this.fluency,
    required this.wordScores,
    required this.phonemeScores,
  });

  factory PronunciationResult.fromJson(Map<String, dynamic> json) =>
      PronunciationResult(
        overallScore: (json['overall_score'] as num?)?.toDouble() ?? 0,
        fluency: (json['fluency'] as num?)?.toDouble() ?? 0,
        wordScores: (json['word_scores'] as List? ?? [])
            .map((e) => WordScore.fromJson(e as Map<String, dynamic>))
            .toList(),
        phonemeScores: (json['phoneme_scores'] as List? ?? [])
            .map((e) => PhonemeScore.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
