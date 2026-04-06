import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/quiz_model.dart';
import '../models/result_model.dart';
import '../models/user_model.dart';
import '../services/local_math_question_service.dart';
import '../services/local_logical_reasoning_question_service.dart';
import '../services/local_verbal_ability_question_service.dart';
import '../services/local_it_theory_question_service.dart';
import '../services/local_it_code_question_service.dart';
import '../services/firestore_service.dart';
import '../services/streak_service.dart';
import '../utils/constants.dart';

class QuizProvider with ChangeNotifier {
  final LocalMathQuestionService _localMathQuestionService = LocalMathQuestionService();
  final LocalLogicalReasoningQuestionService _localLogicalReasoningService = LocalLogicalReasoningQuestionService();
  final LocalVerbalAbilityQuestionService _localVerbalAbilityQuestionService =
      LocalVerbalAbilityQuestionService();
  final LocalITTheoryQuestionService _localITTheoryQuestionService =
      LocalITTheoryQuestionService();
  final LocalITCodeQuestionService _localITCodeQuestionService =
      LocalITCodeQuestionService();
  final FirestoreService _firestoreService = FirestoreService();
  final StreakService _streakService = StreakService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Quiz? _currentQuiz;
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _timer;
  int _remainingSeconds = 0;
  DateTime? _questionStartTime;

  Quiz? get currentQuiz => _currentQuiz;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get remainingSeconds => _remainingSeconds;

  Question? get currentQuestion {
    if (_currentQuiz == null || _currentQuiz!.questions.isEmpty) return null;
    if (_currentQuestionIndex >= _currentQuiz!.questions.length) return null;
    return _currentQuiz!.questions[_currentQuestionIndex];
  }

  bool get isQuizActive => _currentQuiz != null;

  bool get isLastQuestion =>
      _currentQuiz != null &&
          _currentQuestionIndex >= _currentQuiz!.questions.length - 1;

  double get progress {
    if (_currentQuiz == null || _currentQuiz!.questions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / _currentQuiz!.questions.length;
  }

  // ================= START QUIZ =================
  /// Quiz is only available for Mathematics; questions come from local JSON.
  Future<bool> startQuiz({
    required String userId,
    required String subject,
    required String difficulty,
    required int questionCount,
    String? itPart, // "theory" | "code"
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      List<Question> questions;

      String normalizeSubject(String s) =>
          s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

      final normalized = normalizeSubject(subject);

      if (normalized == normalizeSubject(AppConstants.mathSubject)) {
        questions = await _localMathQuestionService.getQuestions(
          subject: subject,
          difficulty: difficulty,
          count: questionCount,
        );
      } else if (normalized == normalizeSubject(AppConstants.reasoningSubject)) {
        questions = await _localLogicalReasoningService.getQuestions(
          subject: subject,
          difficulty: difficulty,
          count: questionCount,
        );
      } else if (normalized == normalizeSubject(AppConstants.varcSubject)) {
        questions = await _localVerbalAbilityQuestionService.getQuestions(
          subject: subject,
          difficulty: difficulty,
          count: questionCount,
        );
      } else if (normalized == normalizeSubject(AppConstants.itSubject)) {
        final part = (itPart ?? 'theory').trim().toLowerCase();
        if (part == 'code') {
          questions = await _localITCodeQuestionService.getQuestions(
            subject: subject,
            difficulty: difficulty,
            count: questionCount,
          );
        } else {
          questions = await _localITTheoryQuestionService.getQuestions(
            subject: subject,
            difficulty: difficulty,
            count: questionCount,
          );
        }
      } else {
        _isLoading = false;
        _errorMessage =
            'Quiz is currently available only for Mathematics, Logical Reasoning, Verbal Ability, and Information Technology.';
        notifyListeners();
        return false;
      }
      
      if (questions.isEmpty) {
        throw Exception(
          'No questions available for the selected difficulty "$difficulty". Please try a different difficulty level.',
        );
      }

      _currentQuiz = Quiz(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        questions: questions,
        startTime: DateTime.now(),
      );

      _currentQuestionIndex = 0;
      _startQuestionTimer();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ================= TIMER =================
  void _startQuestionTimer() {
    _timer?.cancel();

    if (currentQuestion == null) return;

    _remainingSeconds = currentQuestion!.timeLimitSeconds;
    _questionStartTime = DateTime.now();
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        // Time expired — record how long this question took, then advance
        recordQuestionTime();
        nextQuestion();
      }
    });
  }

  // ================= ANSWER =================
  /// Records the user's answer for the current question and stops the timer.
  /// Always call [recordQuestionTime] before or alongside this.
  void submitAnswer(int selectedOptionIndex) {
    if (_currentQuiz == null || currentQuestion == null) return;

    // Capture time spent before cancelling the timer
    recordQuestionTime();

    _currentQuiz!.userAnswers[_currentQuestionIndex] = selectedOptionIndex;

    _timer?.cancel();
    notifyListeners();
  }

  // ================= NAVIGATION =================
  Future<void> nextQuestion() async {
    _timer?.cancel();
    // Record time if not already recorded for this question
    // (guard inside recordQuestionTime handles double-recording)
    _recordIfNotYet();
    await _moveToNext();
  }

  Future<void> skipQuestion() async {
    await nextQuestion();
  }

  // ================= CORE LOGIC =================
  Future<void> _moveToNext() async {
    if (_currentQuiz == null) return;

    if (_currentQuestionIndex < _currentQuiz!.questions.length - 1) {
      _currentQuestionIndex++;
      _startQuestionTimer();
      notifyListeners();
    } else {
      await _finishQuiz();
      notifyListeners();
    }
  }

  /// Records how many seconds were spent on the current question.
  /// Safe to call multiple times — only records once per question index.
  void recordQuestionTime() {
    if (_currentQuiz == null || _questionStartTime == null) return;

    // Already recorded for this index — skip
    if (_currentQuiz!.questionTimeTaken.containsKey(_currentQuestionIndex)) {
      return;
    }

    final elapsed =
        DateTime.now().difference(_questionStartTime!).inSeconds;

    final capped =
    elapsed.clamp(0, currentQuestion?.timeLimitSeconds ?? 30);

    _currentQuiz!.questionTimeTaken[_currentQuestionIndex] = capped;
  }

  /// Called before advancing to ensure time is recorded when the user taps
  /// "Next" without having explicitly submitted (e.g. skipping).
  void _recordIfNotYet() {
    if (_currentQuiz == null) return;
    if (!_currentQuiz!.questionTimeTaken.containsKey(_currentQuestionIndex)) {
      recordQuestionTime();
    }
  }

  // ================= FINISH QUIZ =================
  Future<void> _finishQuiz() async {
    if (_currentQuiz == null) return;

    _timer?.cancel();
    _currentQuiz!.endTime = DateTime.now();

    // Update streak
    try {
      final doc = await _db
          .collection('users')
          .doc(_currentQuiz!.userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromMap(doc.data()!, doc.id);
        await _streakService.updateStreak(user);
      }
    } catch (e) {
      debugPrint('Streak error: $e');
    }

    // Persist result
    try {
      final result = _buildResult();
      if (result != null) {
        await _firestoreService.saveQuizResult(result);
        // Save full quiz questions + answers for History review.
        await _firestoreService.saveQuizQuestions(
          userId: result.userId,
          quizId: result.quizId,
          questions: _currentQuiz!.questions.map((q) => q.toMap()).toList(),
          userAnswers: _currentQuiz!.userAnswers,
          expiresAt: DateTime.now().add(const Duration(days: 365)),
        );
      }
    } catch (e) {
      debugPrint('Save error: $e');
    }
  }

  // ================= RESULT =================
  QuizResult? getQuizResult() {
    if (_currentQuiz == null || _currentQuiz!.endTime == null) return null;
    return _buildResult();
  }

  QuizResult? _buildResult() {
    final quiz = _currentQuiz;
    if (quiz == null || quiz.endTime == null) return null;

    return QuizResult(
      id: quiz.id,
      userId: quiz.userId,
      quizId: quiz.id,
      completedAt: quiz.endTime!,
      score: quiz.score,
      totalQuestions: quiz.totalQuestions,
      accuracy: quiz.accuracy,
      timeTaken: quiz.timeTaken,
      subjectWiseBreakdown: quiz.subjectWiseBreakdown,
    );
  }

  void resetQuiz() {
    _timer?.cancel();
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _remainingSeconds = 0;
    _questionStartTime = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}