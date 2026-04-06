import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question_model.dart';

class LocalITCodeQuestionService {
  static const String _assetPath = 'assets/it_code_mcqs.json';

  List<Map<String, dynamic>>? _allQuestions;

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
      throw Exception('Failed to load IT code questions from $_assetPath: $e');
    }
  }

  static String _toJsonDifficulty(String difficulty) => difficulty.trim().toLowerCase();

  Future<int> getQuestionCountByDifficulty(String difficulty) async {
    final list = await _loadJson();
    final key = _toJsonDifficulty(difficulty);
    return list.where((q) => (q['difficulty'] as String?)?.trim().toLowerCase() == key).length;
  }

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
      var correctIndex = 0;
      for (int j = 0; j < options.length; j++) {
        if (options[j] == correctAnswer) {
          correctIndex = j;
          break;
        }
      }

      final qText = (raw['question'] as String?) ?? '';
      final code = (raw['code'] as String?) ?? '';
      final language = (raw['language'] as String?) ?? '';
      final combined = '$qText\n\n[$language]\n$code';

      questions.add(
        Question(
          id: 'it_code_${raw['id']}_$i',
          subject: subject,
          questionText: combined,
          options: options,
          correctAnswerIndex: correctIndex,
          difficulty: difficulty,
          timeLimitSeconds: 30,
          explanation: (raw['solution'] as String?) ?? '',
          questionHash: 'local_it_code_${raw['id']}',
          generatedAt: now,
          expiresAt: now.add(const Duration(days: 365)),
          randomSeed: now.millisecondsSinceEpoch + i,
        ),
      );
    }

    return questions;
  }
}

