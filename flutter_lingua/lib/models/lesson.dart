class Lesson {
  final String id;
  final String title;
  final String description;
  final String language;
  final String category;
  final int difficulty;
  final String scenario;
  final int xpReward;
  final String promptTemplate;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.category,
    required this.difficulty,
    required this.scenario,
    required this.xpReward,
    this.promptTemplate = '',
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    language: json['language'] ?? 'es',
    category: json['category'] ?? '',
    difficulty: json['difficulty'] ?? 1,
    scenario: json['scenario'] ?? '',
    xpReward: json['xp_reward'] ?? 0,
    promptTemplate: json['prompt_template'] ?? '',
  );
}

class ActiveLesson {
  final String lessonId;
  final String title;
  final String description;
  final String scenario;
  final String systemPrompt;
  final int xpReward;

  const ActiveLesson({
    required this.lessonId,
    required this.title,
    required this.description,
    required this.scenario,
    required this.systemPrompt,
    required this.xpReward,
  });

  factory ActiveLesson.fromJson(Map<String, dynamic> json) => ActiveLesson(
    lessonId: json['lesson_id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    scenario: json['scenario'] ?? '',
    systemPrompt: json['system_prompt'] ?? '',
    xpReward: json['xp_reward'] ?? 0,
  );
}
