import 'message.dart';

class Conversation {
  final String id;
  final String language;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.language,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get messageCount => messages.length;
  String get lastMessage => messages.isNotEmpty ? messages.last.text : '';
  bool get hasMessages => messages.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'language': language,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'],
        language: json['language'],
        messages: (json['messages'] as List)
            .map((m) => Message.fromJson(m))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}
