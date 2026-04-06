import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/question_model.dart';
import '../../models/result_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class HistoryReviewScreen extends StatefulWidget {
  final QuizResult result;

  const HistoryReviewScreen({super.key, required this.result});

  @override
  State<HistoryReviewScreen> createState() => _HistoryReviewScreenState();
}

class _HistoryReviewScreenState extends State<HistoryReviewScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _loading = true;
  String? _error;
  List<Question> _questions = const [];
  Map<int, int> _userAnswers = const {};
  final Map<int, bool> _showSolutionByIndex = {};

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user == null) {
        setState(() {
          _loading = false;
          _error = 'Please log in to view history review.';
        });
        return;
      }

      final data = await _firestoreService.getQuizQuestions(
        userId: user.uid,
        quizId: widget.result.quizId,
      );

      if (data == null) {
        setState(() {
          _loading = false;
          _error =
              'Detailed review is not available for this attempt (missing or expired). Please take a new quiz.';
        });
        return;
      }

      final questionsRaw = List<Map<String, dynamic>>.from(data['questions'] as List);
      final ua = Map<int, int>.from(data['userAnswers'] as Map<int, int>);

      final questions = questionsRaw.map(Question.fromMap).toList();
      final showMap = <int, bool>{};
      for (var i = 0; i < questions.length; i++) {
        showMap[i] = false;
      }

      setState(() {
        _questions = questions;
        _userAnswers = ua;
        _showSolutionByIndex
          ..clear()
          ..addAll(showMap);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'hard':
        return Colors.redAccent;
      case 'medium':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Review'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReview,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'You scored ${widget.result.score} / ${widget.result.totalQuestions}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        _questions.length,
                        (index) => _buildQuestionCard(index),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = _questions[index];
    final selectedIndex = _userAnswers[index];
    final correctIndex = question.correctAnswerIndex;
    final isCorrect = selectedIndex != null && selectedIndex == correctIndex;
    final hasAnswer = selectedIndex != null;

    // IT code questions are stored in Question.questionText with an embedded code block.
    String mainText = question.questionText;
    String? codeText;
    if (question.subject == AppConstants.itSubject && question.questionText.contains('\n[')) {
      final splitIndex = question.questionText.indexOf('\n[');
      if (splitIndex > 0) {
        mainText = question.questionText.substring(0, splitIndex).trimRight();
        codeText = question.questionText.substring(splitIndex + 1).trimRight();
      }
    }

    final statusColor = isCorrect ? Colors.green : Colors.redAccent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    question.difficulty.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _difficultyColor(question.difficulty),
                    ),
                  ),
                  backgroundColor: _difficultyColor(question.difficulty).withOpacity(0.12),
                  side: BorderSide(color: _difficultyColor(question.difficulty)),
                ),
                const Spacer(),
                if (hasAnswer)
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCorrect ? 'CORRECT' : 'INCORRECT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'NOT ANSWERED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mainText,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            if (codeText != null && codeText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        codeText,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Column(
              children: List.generate(question.options.length, (optIndex) {
                final optText = question.options[optIndex];
                final isCorrectOption = optIndex == correctIndex;
                final isSelectedOption = selectedIndex == optIndex;

                Color? tileColor;
                Color textColor = Colors.black87;
                if (isCorrectOption) {
                  tileColor = Colors.green.withOpacity(0.12);
                  textColor = Colors.green.shade800;
                } else if (isSelectedOption && !isCorrectOption) {
                  tileColor = Colors.red.withOpacity(0.12);
                  textColor = Colors.red.shade800;
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: RadioListTile<int>(
                    value: optIndex,
                    groupValue: selectedIndex,
                    onChanged: null,
                    dense: true,
                    title: Text(
                      optText,
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              'Correct answer: ${question.options[correctIndex]}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showSolutionByIndex[index] = !(_showSolutionByIndex[index] ?? false);
                  });
                },
                icon: Icon(
                  (_showSolutionByIndex[index] ?? false) ? Icons.visibility_off : Icons.visibility,
                ),
                label: Text(
                  (_showSolutionByIndex[index] ?? false) ? 'Hide Solution' : 'View Solution',
                ),
              ),
            ),
            if (_showSolutionByIndex[index] ?? false)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
                ),
                child: Text(
                  question.explanation,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

