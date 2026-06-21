class CorrectionWord {
  final String word;
  final String translation;

  const CorrectionWord({required this.word, required this.translation});

  factory CorrectionWord.fromJson(Map<String, dynamic> json) =>
      CorrectionWord(word: json['word'] ?? '', translation: json['translation'] ?? '');
}

class CorrectionDetail {
  final String error;
  final String fix;

  const CorrectionDetail({required this.error, required this.fix});

  factory CorrectionDetail.fromJson(Map<String, dynamic> json) =>
      CorrectionDetail(error: json['error'] ?? '', fix: json['fix'] ?? '');
}

class Correction {
  final String corrected;
  final bool hasErrors;
  final List<CorrectionDetail> corrections;
  final List<CorrectionWord> vocab;

  const Correction({
    this.corrected = '',
    this.hasErrors = false,
    this.corrections = const [],
    this.vocab = const [],
  });

  factory Correction.fromJson(Map<String, dynamic> json) => Correction(
    corrected: json['corrected'] ?? '',
    hasErrors: json['has_errors'] ?? false,
    corrections: (json['corrections'] as List?)
        ?.map((e) => CorrectionDetail.fromJson(e))
        .toList() ?? [],
    vocab: (json['vocab'] as List?)
        ?.map((e) => CorrectionWord.fromJson(e))
        .toList() ?? [],
  );
}
