import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'es';
  String _nativeLanguage = 'en';

  String get currentLanguage => _currentLanguage;
  String get nativeLanguage => _nativeLanguage;

  void initNativeLanguage(String lang) {
    _nativeLanguage = lang;
  }

  void setLanguage(String lang) {
    if (_currentLanguage != lang) {
      _currentLanguage = lang;
      notifyListeners();
    }
  }

  Future<void> setNativeLanguage(String lang) async {
    if (_nativeLanguage != lang) {
      _nativeLanguage = lang;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('native_language', lang);
      notifyListeners();
    }
  }
}
