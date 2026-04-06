import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../models/result_model.dart';
import '../../models/quiz_model.dart';
import '../../utils/constants.dart';
import '../../widgets/confetti_animation.dart';
import '../../widgets/animated_button.dart';
import '../home/home_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  bool _showConfetti = false;
  final Map<int, bool> _showSolutionByIndex = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.extraLongAnimationDuration,
      vsync: this,
    );

    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final quiz = quizProvider.currentQuiz;
    if (quiz != null) {
      for (var i = 0; i < quiz.questions.length; i++) {
        _showSolutionByIndex[i] = false;
      }
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _controller.forward();

      final result = quizProvider.getQuizResult();
      if (result != null && result.accuracy >= AppConstants.goodThreshold) {
        setState(() => _showConfetti = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final result = quizProvider.getQuizResult();
    final quiz = quizProvider.currentQuiz;

    if (result == null || quiz == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: const Center(child: Text('No quiz data available')),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        _navigateHome(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Animated score card
                  AnimatedBuilder(
                    animation: _scoreAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _scoreAnimation.value,
                        child: Transform.scale(
                          scale: 0.8 + (_scoreAnimation.value * 0.2),
                          child: _buildAnimatedScoreCard(context, result),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Celebration message
                  FadeTransition(
                    opacity: _scoreAnimation,
                    child: _buildCelebrationMessage(context, result),
                  ),

                  const SizedBox(height: 24),

                  // Subject-wise breakdown
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_scoreAnimation),
                    child: FadeTransition(
                      opacity: _scoreAnimation,
                      child: _buildSubjectBreakdown(context, result),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats row
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_scoreAnimation),
                    child: FadeTransition(
                      opacity: _scoreAnimation,
                      child: _buildStatsRow(result),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Motivational message
                  FadeTransition(
                    opacity: _scoreAnimation,
                    child: _buildMotivationalMessage(context, result),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  FadeTransition(
                    opacity: _scoreAnimation,
                    child: _buildActionButtons(context, quizProvider),
                  ),
                  const SizedBox(height: 24),

                  // Question review with solutions
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Question Review',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(
                      quiz.questions.length,
                      (index) => _buildQuestionReviewCard(
                        context,
                        quiz,
                        index,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Confetti overlay
            if (_showConfetti)
              Positioned.fill(
                child: IgnorePointer(
                  child: ConfettiAnimation(
                    isActive: _showConfetti,
                    numberOfParticles: 60,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateHome(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.resetQuiz();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
    );
  }

  Widget _buildAnimatedScoreCard(BuildContext context, QuizResult result) {
    final color = result.accuracy >= AppConstants.excellentThreshold
        ? AppConstants.successColor
        : result.accuracy >= AppConstants.goodThreshold
        ? AppConstants.accentColor
        : result.accuracy >= AppConstants.averageThreshold
        ? AppConstants.warningColor
        : AppConstants.errorColor;

    final gradient = LinearGradient(
      colors: [color, color.withOpacity(0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Trophy / medal emoji based on score
          Text(
            result.accuracy >= AppConstants.excellentThreshold
                ? '🏆'
                : result.accuracy >= AppConstants.goodThreshold
                ? '🥇'
                : result.accuracy >= AppConstants.averageThreshold
                ? '⭐'
                : '💪',
            style: const TextStyle(fontSize: 48),
          ),

          const SizedBox(height: 16),

          const Text(
            'Your Score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          // Animated score percentage counter
          TweenAnimationBuilder<double>(
            duration: AppConstants.extraLongAnimationDuration,
            tween: Tween(begin: 0, end: result.accuracy),
            builder: (context, value, child) {
              return Text(
                '${value.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Correct / total — uses totalQuestions directly, no derivation needed
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${result.score} / ${result.totalQuestions} correct',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionReviewCard(
    BuildContext context,
    Quiz quiz,
    int index,
  ) {
    final question = quiz.questions[index];
    final selectedIndex = quiz.userAnswers[index];
    final correctIndex = question.correctAnswerIndex;
    final isCorrect = selectedIndex != null && selectedIndex == correctIndex;
    final hasAnswer = selectedIndex != null;

    // Try to split question text into description + optional code block.
    String mainText = question.questionText;
    String? codeText;
    if (question.subject == AppConstants.itSubject &&
        question.questionText.contains('\n[')) {
      final splitIndex = question.questionText.indexOf('\n[');
      if (splitIndex > 0) {
        mainText =
            question.questionText.substring(0, splitIndex).trimRight();
        codeText =
            question.questionText.substring(splitIndex + 1).trimRight();
      }
    }

    Color headerStatusColor =
        isCorrect ? Colors.green : Colors.redAccent;
    String headerStatusText = isCorrect ? 'CORRECT' : 'INCORRECT';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  backgroundColor: _difficultyColor(
                          question.difficulty)
                      .withOpacity(0.12),
                  side: BorderSide(
                    color: _difficultyColor(question.difficulty),
                  ),
                ),
                const Spacer(),
                if (hasAnswer)
                  Row(
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 18,
                        color: headerStatusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        headerStatusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: headerStatusColor,
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
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
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
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
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
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
                    _showSolutionByIndex[index] =
                        !(_showSolutionByIndex[index] ?? false);
                  });
                },
                icon: Icon(
                  (_showSolutionByIndex[index] ?? false)
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                label: Text(
                  (_showSolutionByIndex[index] ?? false)
                      ? 'Hide Solution'
                      : 'View Solution',
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
                  border: Border.all(
                    color: Colors.blueGrey.withOpacity(0.3),
                  ),
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

  Widget _buildCelebrationMessage(BuildContext context, QuizResult result) {
    final message = AppConstants.getRandomCelebrationMessage(result.accuracy);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSubjectBreakdown(BuildContext context, QuizResult result) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bar_chart,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Subject Performance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...result.subjectWiseBreakdown.entries.map((entry) {
              final subject = entry.key;
              final data = entry.value;
              final correct = data['correct'] ?? 0;
              final total = data['total'] ?? 0;
              final percentage =
              total > 0 ? (correct / total) * 100 : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSubjectBar(
                    subject, correct, total, percentage),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectBar(
      String subject, int correct, int total, double percentage) {
    final color = AppConstants.getSubjectColor(subject);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppConstants.subjectEmojis[subject] ?? '📝',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subject.length > 30
                    ? '${subject.substring(0, 30)}...'
                    : subject,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                '$correct/$total',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            duration: AppConstants.longAnimationDuration,
            tween: Tween(begin: 0, end: percentage / 100),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(QuizResult result) {
    final minutes = result.timeTaken ~/ 60;
    final seconds = result.timeTaken % 60;

    // Average seconds per question — total time / number of questions
    final avgSecs = result.totalQuestions > 0
        ? (result.timeTaken / result.totalQuestions).round()
        : 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                Icons.access_time_filled,
                'Time Taken',
                '${minutes}m ${seconds}s',
                AppConstants.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.emoji_events,
                'Accuracy',
                '${result.accuracy.toStringAsFixed(0)}%',
                AppConstants.warningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                Icons.quiz_outlined,
                'Questions',
                '${result.totalQuestions}',
                AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.timer_outlined,
                'Avg / Question',
                '${avgSecs}s',
                AppConstants.successColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalMessage(BuildContext context, QuizResult result) {
    final message = AppConstants.getMotivationalMessage(result.accuracy);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: AppConstants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, QuizProvider quizProvider) {
    return Column(
      children: [
        AnimatedButton(
          text: 'Back to Home',
          onPressed: () => _navigateHome(context),
          gradient: AppConstants.primaryGradient,
          icon: Icons.home,
        ),
        const SizedBox(height: 16),
        AnimatedButton(
          text: 'Take Another Quiz',
          onPressed: () {
            quizProvider.resetQuiz();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
                  (route) => false,
            );
          },
          gradient: AppConstants.successGradient,
          icon: Icons.refresh,
        ),
      ],
    );
  }
}