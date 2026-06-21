import 'correction.dart';
import 'pronunciation_result.dart';
import 'xp_result.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Correction? correction;
  final XpResult? xp;
  final String? audioUrl;
  final PronunciationResult? pronunciationScore;

  Message({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.correction,
    this.xp,
    this.audioUrl,
    this.pronunciationScore,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
