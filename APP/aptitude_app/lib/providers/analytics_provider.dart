import 'package:flutter/foundation.dart';
import '../models/result_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class AnalyticsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<QuizResult> _allResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<QuizResult> get allResults => _allResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all quiz results for a user
  Future<void> loadResults(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _allResults = await _firestoreService.getUserQuizResults(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Get overall statistics
  Map<String, dynamic> getOverallStats() {
    if (_allResults.isEmpty) {
      return {
        'totalQuizzes': 0,
        'averageAccuracy': 0.0,
        'totalTimeTaken': 0,
        'bestScore': 0.0,
        'worstScore': 0.0,
      };
    }

    double totalAccuracy = 0;
    int totalTime = 0;
    double bestScore = _allResults.first.accuracy;
    double worstScore = _allResults.first.accuracy;

    for (var result in _allResults) {
      totalAccuracy += result.accuracy;
      totalTime += result.timeTaken;

      if (result.accuracy > bestScore) bestScore = result.accuracy;
      if (result.accuracy < worstScore) worstScore = result.accuracy;
    }

    return {
      'totalQuizzes': _allResults.length,
      'averageAccuracy': totalAccuracy / _allResults.length,
      'totalTimeTaken': totalTime,
      'bestScore': bestScore,
      'worstScore': worstScore,
    };
  }

  // Get subject-wise performance — works with any subject, not just the preset 3
  Map<String, Map<String, dynamic>> getSubjectWisePerformance() {
    // Collect accuracy scores per subject across all results
    final Map<String, List<double>> subjectScores = {};

    // Pre-seed with known subjects so they always appear even with 0 data
    for (final subject in AppConstants.subjects) {
      subjectScores[subject] = [];
    }

    for (final result in _allResults) {
      for (final entry in result.subjectWiseBreakdown.entries) {
        final subject = entry.key;
        subjectScores.putIfAbsent(subject, ()=>[]);
        subjectScores[subject]!.add(result.getSubjectAccuracy(subject));
      }
    }

    final Map<String, Map<String, dynamic>> performance = {};

    for (final entry in subjectScores.entries) {
      final subject = entry.key;
      final scores = entry.value;

      if (scores.isNotEmpty) {
        final average = scores.reduce((a, b) => a + b) / scores.length;
        final best = scores.reduce((a, b) => a > b ? a : b);
        final worst = scores.reduce((a, b) => a < b ? a : b);

        performance[subject] = {
          'average': average,
          'best': best,
          'worst': worst,
          'total': scores.length, // int — NOT double
        };
      } else {
        performance[subject] = {
          'average': 0.0,
          'best': 0.0,
          'worst': 0.0,
          'total': 0, // int — NOT double
        };
      }
    }

    return performance;
  }

  // Get data for chart (recent results)
  List<Map<String, dynamic>> getChartData({int limit = 10}) {
    final recentResults = _allResults.take(limit).toList().reversed.toList();

    return List.generate(recentResults.length, (i) {
      final result = recentResults[i];
      return {
        'index': i,
        'date': result.completedAt,
        AppConstants.mathSubject:
        result.getSubjectAccuracy(AppConstants.mathSubject),
        AppConstants.reasoningSubject:
        result.getSubjectAccuracy(AppConstants.reasoningSubject),
        AppConstants.varcSubject:
        result.getSubjectAccuracy(AppConstants.varcSubject),
      };
    });
  }

  // Identify weak subjects (average below threshold, with at least 1 attempt)
  List<String> getWeakSubjects() {
    final performance = getSubjectWisePerformance();
    final weakSubjects = performance.entries
        .where((e) =>
    (e.value['total'] as int) > 0 &&
        (e.value['average'] as double) < AppConstants.averageThreshold)
        .map((e) => e.key)
        .toList();

    // Sort by average score ascending (worst first)
    weakSubjects.sort((a, b) => (performance[a]!['average'] as double)
        .compareTo(performance[b]!['average'] as double));

    return weakSubjects;
  }

  // Get trend for overall performance
  String getOverallTrend() {
    if (_allResults.length < 3) return 'Stable';

    final recent = _allResults.take(3).toList();
    final older = _allResults.skip(3).take(3).toList();

    if (older.isEmpty) return 'Stable';

    final recentAvg =
        recent.map((r) => r.accuracy).reduce((a, b) => a + b) / recent.length;
    final olderAvg =
        older.map((r) => r.accuracy).reduce((a, b) => a + b) / older.length;

    if (recentAvg > olderAvg + 5) return 'Improving';
    if (recentAvg < olderAvg - 5) return 'Declining';
    return 'Stable';
  }

  // Get last quiz score
  double? getLastQuizScore() {
    if (_allResults.isEmpty) return null;
    return _allResults.first.accuracy;
  }
}