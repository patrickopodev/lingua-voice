import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/audio_service.dart';
import 'providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedUrl = prefs.getString('server_url') ?? 'https://lingua-voice.onrender.com';
  final nativeLang = prefs.getString('native_language') ?? 'en';

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(baseUrl: savedUrl),
        ),
        Provider<AudioService>(
          create: (_) => AudioService(),
        ),
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => LanguageProvider()..initNativeLanguage(nativeLang),
        ),
      ],
      child: const LinguaVoiceApp(),
    ),
  );
}

class LinguaVoiceApp extends StatelessWidget {
  const LinguaVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinguaVoice',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
