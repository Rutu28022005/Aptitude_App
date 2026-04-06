class QuizResult {
  final String id;
  final String userId;
  final String quizId;
  final DateTime completedAt;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final int timeTaken;
  final Map<String, Map<String, int>> subjectWiseBreakdown;

  QuizResult({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.completedAt,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.timeTaken,
    required this.subjectWiseBreakdown,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'completedAt': completedAt.toIso8601String(),
      'score': score,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'timeTaken': timeTaken,
      'subjectWiseBreakdown': subjectWiseBreakdown,
    };
  }

  // Convert from Firebase
  factory QuizResult.fromMap(Map<String, dynamic> map, String id) {
    final rawBreakdown = map['subjectWiseBreakdown'] as Map? ?? {};
    final breakdown = rawBreakdown.map<String, Map<String, int>>(
          (k, v) => MapEntry(
        k.toString(),
        (v as Map).map<String, int>(
              (sk, sv) => MapEntry(sk.toString(), (sv as num).toInt()),
        ),
      ),
    );

    final storedTotal = map['totalQuestions'];
    final totalQuestions = storedTotal != null
        ? (storedTotal as num).toInt()
        : breakdown.values.fold<int>(0, (sum, d) => sum + (d['total'] ?? 0));

    return QuizResult(
      id: id,
      userId: map['userId'] ?? '',
      quizId: map['quizId'] ?? '',
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : DateTime.now(),
      score: (map['score'] as num? ?? 0).toInt(),
      totalQuestions: totalQuestions,
      accuracy: (map['accuracy'] as num? ?? 0.0).toDouble(),
      timeTaken: (map['timeTaken'] as num? ?? 0).toInt(),
      subjectWiseBreakdown: breakdown,
    );
  }

  double getSubjectAccuracy(String subject) {
    if (!subjectWiseBreakdown.containsKey(subject)) return 0.0;
    final data = subjectWiseBreakdown[subject]!;
    final total = data['total'] ?? 0;
    final correct = data['correct'] ?? 0;
    if (total == 0) return 0.0;
    return (correct / total) * 100;
  }
}