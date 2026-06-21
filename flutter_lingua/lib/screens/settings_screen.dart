import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';
import '../providers/language_provider.dart';
import '../widgets/language_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final api = context.read<ApiService>();
    _urlController = TextEditingController(text: api.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final api = context.read<ApiService>();
    api.updateBaseUrl(_urlController.text);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', _urlController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Server URL updated - no restart needed')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Server URL',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: 'http://localhost:8000',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
          const SizedBox(height: 32),
          const Text('Target Language',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LanguageSelector(
            selectedLanguage: lang.currentLanguage,
            onChanged: (value) => lang.setLanguage(value),
          ),
          const SizedBox(height: 32),
          const Text('Native Language (for translations)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: lang.nativeLanguage,
            items: LanguageService.languages.map((l) {
              return DropdownMenuItem(
                value: l.code,
                child: Text('${l.flag} ${l.name}'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) lang.setNativeLanguage(value);
            },
            underline: const SizedBox(),
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
