import 'question_model.dart';

class Quiz {
  final String id;
  final String userId;
  final List<Question> questions;
  final DateTime startTime;
  DateTime? endTime;
  final Map<int, int> userAnswers;
  final Map<int, int> questionTimeTaken;

  Quiz({
    required this.id,
    required this.userId,
    required this.questions,
    required this.startTime,
    this.endTime,
    Map<int, int>? userAnswers,
    Map<int, int>? questionTimeTaken,
  })  : userAnswers = userAnswers ?? {},
        questionTimeTaken = questionTimeTaken ?? {};

  // Calculate score
  int get score {
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers.containsKey(i)) {
        if (userAnswers[i] == questions[i].correctAnswerIndex) {
          correct++;
        }
      }
    }
    return correct;
  }

  // Total number of questions
  int get totalQuestions => questions.length;

  // Calculate accuracy percentage
  double get accuracy {
    if (questions.isEmpty) return 0.0;
    return (score / questions.length) * 100;
  }

  // Calculate time taken in seconds
  int get timeTaken {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inSeconds;
  }

  // Average seconds per question (using per-question timers when available)
  double get averageTimePerQuestion {
    if (questions.isEmpty) return 0.0;
    if (questionTimeTaken.isEmpty) {
      return timeTaken / questions.length;
    }
    final total = questionTimeTaken.values.fold<int>(0, (s, v) => s + v);
    return total / questions.length;
  }

  // Get subject-wise breakdown
  Map<String, Map<String, int>> get subjectWiseBreakdown {
    final Map<String, Map<String, int>> breakdown = {};

    for (int i = 0; i < questions.length; i++) {
      final subject = questions[i].subject;

      breakdown.putIfAbsent(subject, () => {'total': 0, 'correct': 0});
      breakdown[subject]!['total'] = breakdown[subject]!['total']! + 1;

      if (userAnswers.containsKey(i) &&
          userAnswers[i] == questions[i].correctAnswerIndex) {
        breakdown[subject]!['correct'] = breakdown[subject]!['correct']! + 1;
      }
    }

    return breakdown;
  }

  // Per-subject average time in seconds
  Map<String, double> get subjectWiseAvgTime {
    final Map<String, List<int>> times = {};

    for (int i = 0; i < questions.length; i++) {
      final subject = questions[i].subject;
      times.putIfAbsent(subject, () => []);
      if (questionTimeTaken.containsKey(i)) {
        times[subject]!.add(questionTimeTaken[i]!);
      }
    }

    return times.map((subject, list) {
      if (list.isEmpty) return MapEntry(subject, 0.0);
      return MapEntry(
          subject, list.fold<int>(0, (s, v) => s + v) / list.length);
    });
  }

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'questions': questions.map((q) => q.toMap()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'userAnswers': userAnswers.map((k, v) => MapEntry(k.toString(), v)),
      'questionTimeTaken':
      questionTimeTaken.map((k, v) => MapEntry(k.toString(), v)),
      'score': score,
      'accuracy': accuracy,
      'timeTaken': timeTaken,
      'totalQuestions': totalQuestions,
      'subjectWiseBreakdown': subjectWiseBreakdown,
    };
  }

  // Convert from Firebase
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      questions: (map['questions'] as List?)
          ?.map((q) => Question.fromMap(q))
          .toList() ??
          [],
      startTime: map['startTime'] != null
          ? DateTime.parse(map['startTime'])
          : DateTime.now(),
      endTime:
      map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      userAnswers: (map['userAnswers'] as Map?)?.map(
            (k, v) => MapEntry(int.parse(k.toString()), (v as num).toInt()),
      ) ??
          {},
      questionTimeTaken: (map['questionTimeTaken'] as Map?)?.map(
            (k, v) => MapEntry(int.parse(k.toString()), (v as num).toInt()),
      ) ??
          {},
    );
  }
}