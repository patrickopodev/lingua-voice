import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../models/correction.dart';
import '../models/xp_result.dart';
import '../models/lesson.dart';
import '../models/pronunciation_result.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../providers/language_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/record_button.dart';
import '../widgets/xp_notification.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  final Lesson? lesson;

  const ChatScreen({super.key, this.lesson});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _userId = 'default';

  String get _selectedLanguage =>
      widget.lesson?.language ?? context.read<LanguageProvider>().currentLanguage;
  bool _isProcessing = false;
  bool _inLessonMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.lesson != null) {
      _inLessonMode = true;
      setState(() {
        _messages.add(Message(
          text: 'Starting: ${widget.lesson!.title}\n${widget.lesson!.description}',
          isUser: false,
        ));
      });
    }
  }

  Future<void> _sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _isProcessing = true;
    });

    try {
      final api = context.read<ApiService>();
      final history = _messages
          .take(_messages.length - 1)
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text
              })
          .toList();

      final result = await api.chat(text, _selectedLanguage, history,
          userId: _userId);
      final responseText = result['response'] as String? ?? '';

      final aiMsg = Message(
        text: responseText,
        isUser: false,
        correction: result['correction'] != null
            ? Correction.fromJson(result['correction'])
            : null,
        xp: result['xp'] != null
            ? XpResult.fromJson(result['xp'])
            : null,
        audioUrl: result['audio_url'],
      );

      setState(() => _messages.add(aiMsg));

      if (aiMsg.xp != null) {
        showXpNotification(context, aiMsg.xp!);
      }

      if (result['audio_url'] != null) {
        await context.read<AudioService>().playAudioUrl('${api.baseUrl}${result['audio_url']}');
      }
    } catch (e) {
      setState(() {
        _messages.add(Message(text: 'Error: $e', isUser: false));
      });
    } finally {
      setState(() => _isProcessing = false);
      _scrollToBottom();
    }
  }

  Future<void> _sendVoiceMessage(File audioFile) async {
    setState(() => _isProcessing = true);
    try {
      final api = context.read<ApiService>();
      final audio = context.read<AudioService>();
      final result = await api.conversation(
        audioFile, _selectedLanguage,
        userId: _userId,
        lessonId: widget.lesson?.id,
      );

      final userText = result['user_text'] as String? ?? '';
      PronunciationResult? pronunciationScore;

      try {
        final scoreResult = await api.pronounce(audioFile, userText, _selectedLanguage);
        pronunciationScore = PronunciationResult.fromJson(scoreResult);
      } catch (_) {}

      final userMsg = Message(
        text: userText,
        isUser: true,
        pronunciationScore: pronunciationScore,
      );
      final aiMsg = Message(
        text: result['response'],
        isUser: false,
        correction: result['correction'] != null
            ? Correction.fromJson(result['correction'])
            : null,
        xp: result['xp'] != null
            ? XpResult.fromJson(result['xp'])
            : null,
        audioUrl: result['audio_url'],
      );

      setState(() {
        _messages.add(userMsg);
        _messages.add(aiMsg);
      });

      await audio.playAudioUrl('${api.baseUrl}${result['audio_url']}');

      if (aiMsg.xp != null) {
        showXpNotification(context, aiMsg.xp!);
      }
    } catch (e) {
      setState(() {
        _messages.add(Message(text: 'Error: $e', isUser: false));
      });
    } finally {
      setState(() => _isProcessing = false);
      _scrollToBottom();
    }
  }

  Future<void> _speakResponse(String text) async {
    try {
      final api = context.read<ApiService>();
      final audio = await api.speak(text, _selectedLanguage);
      await context.read<AudioService>().playAudio(audio);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TTS failed: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final nativeLang = lang.nativeLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(_inLessonMode ? widget.lesson!.title : 'LinguaVoice'),
        actions: [
          if (!_inLessonMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: LanguageSelectorWidget(
                selectedLanguage: _selectedLanguage,
                onChanged: (value) => lang.setLanguage(value),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_inLessonMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.shade50,
              child: Row(
                children: [
                  Icon(Icons.school, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text('Lesson Mode', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                  const Spacer(),
                  Text('+${widget.lesson!.xpReward} XP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: _messages[index],
                  nativeLanguage: nativeLang,
                );
              },
            ),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (text) {
                      _sendTextMessage(text);
                      _textController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                RecordButton(
                  onRecordingComplete: _sendVoiceMessage,
                  disabled: _isProcessing,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isProcessing
                      ? null
                      : () {
                          _sendTextMessage(_textController.text);
                          _textController.clear();
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageSelectorWidget extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  const LanguageSelectorWidget({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedLanguage,
      items: const [
        DropdownMenuItem(value: 'en', child: Text('\u{1F1EC}\u{1F1E7} EN')),
        DropdownMenuItem(value: 'es', child: Text('\u{1F1EA}\u{1F1F8} ES')),
        DropdownMenuItem(value: 'fr', child: Text('\u{1F1EB}\u{1F1F7} FR')),
        DropdownMenuItem(value: 'de', child: Text('\u{1F1E9}\u{1F1EA} DE')),
        DropdownMenuItem(value: 'it', child: Text('\u{1F1EE}\u{1F1F9} IT')),
        DropdownMenuItem(value: 'pt', child: Text('\u{1F1F5}\u{1F1F9} PT')),
        DropdownMenuItem(value: 'ru', child: Text('\u{1F1F7}\u{1F1FA} RU')),
        DropdownMenuItem(value: 'ja', child: Text('\u{1F1EF}\u{1F1F5} JA')),
        DropdownMenuItem(value: 'ko', child: Text('\u{1F1F0}\u{1F1F7} KO')),
        DropdownMenuItem(value: 'zh', child: Text('\u{1F1E8}\u{1F1F3} ZH')),
        DropdownMenuItem(value: 'ar', child: Text('\u{1F1F8}\u{1F1E6} AR')),
        DropdownMenuItem(value: 'hi', child: Text('\u{1F1EE}\u{1F1F3} HI')),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
