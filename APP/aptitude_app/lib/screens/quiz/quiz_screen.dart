import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/quiz_timer.dart';
import '../../utils/constants.dart';
import 'result_screen.dart';
import '../home/home_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedOption;



  Future<void> _submitAndNext() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    // Record time spent on this question before moving away
    quizProvider.recordQuestionTime();

    if (_selectedOption != null) {
      quizProvider.submitAnswer(_selectedOption!);
    }

    if (quizProvider.isLastQuestion) {
      await quizProvider.nextQuestion();
      if (mounted) _showResultsDialog(quizProvider);
    } else {
      await quizProvider.nextQuestion();
      setState(() {
        _selectedOption = null;
      });
    }
  }

  void _showResultsDialog(QuizProvider quizProvider) {
    final result = quizProvider.getQuizResult();
    if (result == null) return;

    final color = result.accuracy >= AppConstants.excellentThreshold
        ? AppConstants.successColor
        : result.accuracy >= AppConstants.goodThreshold
        ? AppConstants.accentColor
        : result.accuracy >= AppConstants.averageThreshold
        ? AppConstants.warningColor
        : AppConstants.errorColor;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.accuracy >= AppConstants.excellentThreshold
                    ? '🏆'
                    : result.accuracy >= AppConstants.goodThreshold
                    ? '🥇'
                    : result.accuracy >= AppConstants.averageThreshold
                    ? '⭐'
                    : '💪',
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                'Quiz Complete!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${result.accuracy.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${result.score} correct',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subject Performance',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...result.subjectWiseBreakdown.entries.map((entry) {
                      final subject = entry.key;
                      final data = entry.value;
                      final correct = data['correct'] ?? 0;
                      final total = data['total'] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              AppConstants.subjectEmojis[subject] ?? '📝',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                subject.length > 20
                                    ? '${subject.substring(0, 20)}...'
                                    : subject,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.getSubjectColor(subject)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$correct/$total',
                                style: TextStyle(
                                  color: AppConstants.getSubjectColor(subject),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        quizProvider.resetQuiz();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                              (route) => false,
                        );
                      },
                      child: const Text('Home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ResultScreen(),
                          ),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _skipQuestion() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    // Record time spent even for skipped questions
    quizProvider.recordQuestionTime();

    if (quizProvider.isLastQuestion) {
      await quizProvider.nextQuestion();
      if (mounted) _showResultsDialog(quizProvider);
    } else {
      await quizProvider.skipQuestion();
      setState(() {
        _selectedOption = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz?'),
            content:
            const Text('Your progress will be lost if you exit now.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Continue Quiz'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          automaticallyImplyLeading: false,
          actions: [
            Consumer<QuizProvider>(
              builder: (context, quizProvider, _) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      '${quizProvider.currentQuestionIndex + 1}/${quizProvider.currentQuiz?.questions.length ?? 0}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<QuizProvider>(
          builder: (context, quizProvider, _) {
            final question = quizProvider.currentQuestion;

            if (question == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                LinearProgressIndicator(
                  value: quizProvider.progress,
                  minHeight: 4,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppConstants.getSubjectColor(question.subject),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: QuizTimer(
                            totalSeconds: question.timeLimitSeconds,
                            remainingSeconds: quizProvider.remainingSeconds,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                'Q${quizProvider.currentQuestionIndex + 1}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor:
                                  AppConstants.primaryColor.withOpacity(0.12),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                question.difficulty.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _difficultyColor(question.difficulty),
                                ),
                              ),
                              backgroundColor:
                                  _difficultyColor(question.difficulty)
                                      .withOpacity(0.12),
                              side: BorderSide(
                                color: _difficultyColor(question.difficulty),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                question.subject,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: AppConstants.getSubjectColor(
                                question.subject,
                              ).withOpacity(0.2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          color: Colors.grey[100],
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              question.questionText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Select your answer:',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(question.options.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildOptionCard(
                              index,
                              question.options[index],
                              _selectedOption == index,
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _skipQuestion,
                                child: const Text('Skip'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _selectedOption != null
                                    ? _submitAndNext
                                    : null,
                                child: Text(
                                  quizProvider.isLastQuestion
                                      ? 'Finish'
                                      : 'Next',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index, String option, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
            isSelected ? AppConstants.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppConstants.primaryColor
                    : Colors.grey[300],
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}