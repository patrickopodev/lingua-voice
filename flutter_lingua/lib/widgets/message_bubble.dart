import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../models/correction.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import 'pronunciation_score_card.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final String? nativeLanguage;

  const MessageBubble({
    super.key,
    required this.message,
    this.nativeLanguage,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _translating = false;

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final corr = message.correction;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight: message.isUser
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
                    bottomLeft: message.isUser
                        ? const Radius.circular(16)
                        : const Radius.circular(4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (!message.isUser) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (message.audioUrl != null)
                            _ActionButton(
                              icon: Icons.replay,
                              tooltip: 'Replay response',
                              onPressed: () => _playAudio(message.audioUrl!),
                            ),
                          if (widget.nativeLanguage != null &&
                              widget.nativeLanguage!.isNotEmpty &&
                              widget.nativeLanguage != 'en')
                            const SizedBox(width: 8),
                          if (widget.nativeLanguage != null &&
                              widget.nativeLanguage!.isNotEmpty)
                            _ActionButton(
                              icon: Icons.g_translate,
                              tooltip: 'Hear translation',
                              loading: _translating,
                              onPressed: _translating ? null : () => _translateAndPlay(message.text),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: message.isUser
                            ? Colors.white70
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!message.isUser && corr != null && corr.hasErrors) ...[
            const SizedBox(height: 4),
            _CorrectionCard(correction: corr),
          ],
          if (message.isUser && message.pronunciationScore != null) ...[
            PronunciationScoreCard(result: message.pronunciationScore!),
          ],
          if (!message.isUser && message.xp != null) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '+${message.xp!.xpEarned} XP',
                    style: TextStyle(fontSize: 12, color: Colors.amber.shade800, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _playAudio(String url) async {
    try {
      final audioService = context.read<AudioService>();
      final api = context.read<ApiService>();
      final fullUrl = url.startsWith('http') ? url : '${api.baseUrl}$url';
      await audioService.playAudioUrl(fullUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playback error: $e')),
        );
      }
    }
  }

  Future<void> _translateAndPlay(String text) async {
    setState(() => _translating = true);
    try {
      final api = context.read<ApiService>();
      final result = await api.translateAndSpeak(
        text: text,
        targetLanguage: widget.nativeLanguage!,
      );
      final audioService = context.read<AudioService>();
      await audioService.playAudioUrl('${api.baseUrl}${result['audio_url']}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool loading;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        icon: loading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey.shade600),
              )
            : Icon(icon, size: 16),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        color: Colors.grey.shade600,
      ),
    );
  }
}

class _CorrectionCard extends StatelessWidget {
  final Correction correction;
  const _CorrectionCard({required this.correction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.spellcheck, size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 6),
                Text('Correction', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
              ],
            ),
            const SizedBox(height: 6),
            if (correction.corrected.isNotEmpty)
              Text(
                'Correct: ${correction.corrected}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            const SizedBox(height: 4),
            ...correction.corrections.map((c) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.orange.shade700)),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        children: [
                          TextSpan(text: c.error, style: const TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: ' → ${c.fix}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
            if (correction.vocab.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: correction.vocab.map((v) => Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  label: Text('${v.word} - ${v.translation}', style: const TextStyle(fontSize: 11)),
                  backgroundColor: Colors.orange.shade100,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
