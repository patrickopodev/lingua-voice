import 'package:flutter/material.dart';
import '../services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedLanguage,
      items: LanguageService.languages.map((lang) {
        return DropdownMenuItem(
          value: lang.code,
          child: Text('${lang.flag} ${lang.name}'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      underline: const SizedBox(),
    );
  }
}
