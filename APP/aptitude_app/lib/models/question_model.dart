class Question {
  final String id;
  final String subject;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String difficulty;
  final int timeLimitSeconds;
  final String explanation;
  final String questionHash;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final int randomSeed;
  
  Question({
    required this.id,
    required this.subject,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.difficulty,
    this.timeLimitSeconds = 30,
    this.explanation = '',
    required this.questionHash,
    required this.generatedAt,
    required this.expiresAt,
    required this.randomSeed,
  });
  
  // Convert from AI API response
  factory Question.fromAIResponse(Map<String, dynamic> json, String subject) {
    final now = DateTime.now();
    final questionText = json['question'] ?? '';
    final randomSeed = now.millisecondsSinceEpoch;
    
    return Question(
      id: json['id'] ?? now.millisecondsSinceEpoch.toString(),
      subject: subject,
      questionText: questionText,
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctIndex'] ?? 0,
      difficulty: json['difficulty'] ?? 'Medium',
      timeLimitSeconds: json['timeLimit'] ?? 30,
      explanation: json['explanation'] ?? '',
      questionHash: '', // Will be populated by AI service
      generatedAt: now,
      expiresAt: now.add(Duration(hours: 24)),
      randomSeed: randomSeed,
    );
  }
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'difficulty': difficulty,
      'timeLimitSeconds': timeLimitSeconds,
      'explanation': explanation,
      'questionHash': questionHash,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'randomSeed': randomSeed,
    };
  }
  
  // Convert from Map
  factory Question.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    return Question(
      id: map['id'] ?? '',
      subject: map['subject'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      difficulty: map['difficulty'] ?? 'Medium',
      timeLimitSeconds: map['timeLimitSeconds'] ?? 30,
      explanation: map['explanation'] ?? '',
      questionHash: map['questionHash'] ?? '',
      generatedAt: map['generatedAt'] != null 
          ? DateTime.parse(map['generatedAt']) 
          : now,
      expiresAt: map['expiresAt'] != null 
          ? DateTime.parse(map['expiresAt']) 
          : now.add(Duration(hours: 24)),
      randomSeed: map['randomSeed'] ?? 0,
    );
  }
}
