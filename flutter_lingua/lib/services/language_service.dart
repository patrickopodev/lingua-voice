class Language {
  final String code;
  final String name;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class LanguageService {
  static const List<Language> languages = [
    Language(code: 'en', name: 'English', flag: '\u{1F1EC}\u{1F1E7}'),
    Language(code: 'es', name: 'Spanish', flag: '\u{1F1EA}\u{1F1F8}'),
    Language(code: 'fr', name: 'French', flag: '\u{1F1EB}\u{1F1F7}'),
    Language(code: 'de', name: 'German', flag: '\u{1F1E9}\u{1F1EA}'),
    Language(code: 'it', name: 'Italian', flag: '\u{1F1EE}\u{1F1F9}'),
    Language(code: 'pt', name: 'Portuguese', flag: '\u{1F1F5}\u{1F1F9}'),
    Language(code: 'ru', name: 'Russian', flag: '\u{1F1F7}\u{1F1FA}'),
    Language(code: 'ja', name: 'Japanese', flag: '\u{1F1EF}\u{1F1F5}'),
    Language(code: 'ko', name: 'Korean', flag: '\u{1F1F0}\u{1F1F7}'),
    Language(code: 'zh', name: 'Chinese', flag: '\u{1F1E8}\u{1F1F3}'),
    Language(code: 'ar', name: 'Arabic', flag: '\u{1F1F8}\u{1F1E6}'),
    Language(code: 'hi', name: 'Hindi', flag: '\u{1F1EE}\u{1F1F3}'),
  ];

  static String getLanguageName(String code) {
    return languages.firstWhere(
      (l) => l.code == code,
      orElse: () => const Language(code: 'en', name: 'English', flag: ''),
    ).name;
  }

  static String getLanguageFlag(String code) {
    return languages.firstWhere(
      (l) => l.code == code,
      orElse: () => const Language(code: 'en', name: 'English', flag: ''),
    ).flag;
  }
}
