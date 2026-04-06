import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question_model.dart';
import '../utils/constants.dart';

/// Loads Mathematics/Quantitative Aptitude questions from the bundled
/// quantitative_aptitude_mcqs.json. Used only for the Mathematics subject.
/// No OpenAI or network calls.
class LocalMathQuestionService {
  static const String _assetPath = 'assets/quantitative_aptitude_mcqs.json';

  List<Map<String, dynamic>>? _allQuestions;

  /// Load and parse the JSON asset. Cached after first load.
  Future<List<Map<String, dynamic>>> _loadJson() async {
    if (_allQuestions != null) return _allQuestions!;
    try {
      final String raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw Exception('Expected JSON array, got ${decoded.runtimeType}');
      }
      _allQuestions = (decoded as List<dynamic>).cast<Map<String, dynamic>>();
      return _allQuestions!;
    } catch (e) {
      throw Exception('Failed to load math questions from $_assetPath: $e');
    }
  }

  /// Normalize UI difficulty (e.g. "Easy") to JSON format ("easy").
  static String _toJsonDifficulty(String difficulty) {
    return difficulty.trim().toLowerCase();
  }

  /// Returns the number of questions available for the given difficulty.
  /// difficulty: AppConstants.difficultyEasy / difficultyMedium / difficultyHard.
  Future<int> getQuestionCountByDifficulty(String difficulty) async {
    final list = await _loadJson();
    final key = _toJsonDifficulty(difficulty);
    return list.where((q) => (q['difficulty'] as String?) == key).length;
  }

  /// Fetches [count] questions for the given [difficulty], shuffled.
  /// [subject] should be AppConstants.mathSubject.
  Future<List<Question>> getQuestions({
    required String subject,
    required String difficulty,
    required int count,
  }) async {
    final list = await _loadJson();
    if (list.isEmpty) return [];
    final key = _toJsonDifficulty(difficulty);
    var filtered = list
        .where((q) => (q['difficulty'] as String?)?.trim().toLowerCase() == key)
        .toList();
    if (filtered.isEmpty) filtered = List<Map<String, dynamic>>.from(list);
    filtered.shuffle(Random());
    final take = count.clamp(1, filtered.length);
    final now = DateTime.now();
    final questions = <Question>[];

    for (int i = 0; i < take; i++) {
      final raw = filtered[i];
      final options = List<String>.from(raw['options'] as List<dynamic>);
      final correctAnswer = (raw['correct_answer'] as String?) ?? '';
      int correctIndex = 0;
      for (int j = 0; j < options.length; j++) {
        if (options[j] == correctAnswer) {
          correctIndex = j;
          break;
        }
      }
      questions.add(Question(
        id: 'math_${raw['id']}_$i',
        subject: subject,
        questionText: (raw['question'] as String?) ?? '',
        options: options,
        correctAnswerIndex: correctIndex,
        difficulty: difficulty,
        timeLimitSeconds: 30,
        explanation: (raw['solution'] as String?) ?? '',
        questionHash: 'local_${raw['id']}',
        generatedAt: now,
        expiresAt: now.add(const Duration(days: 365)),
        randomSeed: now.millisecondsSinceEpoch + i,
      ));
    }

    return questions;
  }
}
