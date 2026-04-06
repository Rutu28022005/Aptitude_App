import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../services/local_math_question_service.dart';
import '../../services/local_logical_reasoning_question_service.dart';
import '../../services/local_verbal_ability_question_service.dart';
import '../../services/local_it_theory_question_service.dart';
import '../../services/local_it_code_question_service.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/loading_overlay.dart';
import 'quiz_screen.dart';

class QuizConfigScreen extends StatefulWidget {
  const QuizConfigScreen({super.key});
  
  @override
  State<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends State<QuizConfigScreen> with SingleTickerProviderStateMixin {
  final LocalMathQuestionService _localMathService = LocalMathQuestionService();
  final LocalLogicalReasoningQuestionService _localLRService = LocalLogicalReasoningQuestionService();
  final LocalVerbalAbilityQuestionService _localVAService = LocalVerbalAbilityQuestionService();
  final LocalITTheoryQuestionService _localITTheoryService = LocalITTheoryQuestionService();
  final LocalITCodeQuestionService _localITCodeService = LocalITCodeQuestionService();
  
  String? _selectedSubject;
  String _selectedDifficulty = AppConstants.difficultyMedium;
  int _questionCount = AppConstants.defaultQuestionCount;
  int? _mathAvailableCount;
  int? _lrAvailableCount;
  int? _vaAvailableCount;
  int? _itAvailableCount;
  bool _isStarting = false;

  String _itPart = 'theory'; // theory | code
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  static String _normalizeSubject(String? subject) {
    if (subject == null) return '';
    return subject.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  bool get _isMathematicsSelected {
    if (_selectedSubject == null) return false;
    final selected = _normalizeSubject(_selectedSubject);
    final mathSubject = _normalizeSubject(AppConstants.mathSubject);
    return selected == mathSubject;
  }
  
  bool get _isLogicalReasoningSelected {
    if (_selectedSubject == null) return false;
    final selected = _normalizeSubject(_selectedSubject);
    final reasoningSubject = _normalizeSubject(AppConstants.reasoningSubject);
    return selected == reasoningSubject;
  }

  bool get _isVerbalAbilitySelected {
    if (_selectedSubject == null) return false;
    final selected = _normalizeSubject(_selectedSubject);
    final varc = _normalizeSubject(AppConstants.varcSubject);
    return selected == varc;
  }

  bool get _isITSelected {
    if (_selectedSubject == null) return false;
    final selected = _normalizeSubject(_selectedSubject);
    final it = _normalizeSubject(AppConstants.itSubject);
    return selected == it;
  }
  
  bool get _isQuizAvailable {
    return _isMathematicsSelected ||
        _isLogicalReasoningSelected ||
        _isVerbalAbilitySelected ||
        _isITSelected;
  }
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _animationController.forward();
    _loadCountsIfNeeded();
  }
  
  Future<void> _loadCountsIfNeeded() async {
    if (_isMathematicsSelected) {
      final count = await _localMathService.getQuestionCountByDifficulty(_selectedDifficulty);
      if (!mounted) return;
      setState(() {
        _mathAvailableCount = count;
        _lrAvailableCount = null;
        _vaAvailableCount = null;
        _itAvailableCount = null;
        if (_questionCount > count) _questionCount = count.clamp(AppConstants.minQuestions, count);
      });
    } else if (_isLogicalReasoningSelected) {
      final count = await _localLRService.getQuestionCountByDifficulty(_selectedDifficulty);
      if (!mounted) return;
      setState(() {
        _lrAvailableCount = count;
        _mathAvailableCount = null;
        _vaAvailableCount = null;
        _itAvailableCount = null;
        if (_questionCount > count) _questionCount = count.clamp(AppConstants.minQuestions, count);
      });
    } else if (_isVerbalAbilitySelected) {
      final count = await _localVAService.getQuestionCountByDifficulty(_selectedDifficulty);
      if (!mounted) return;
      setState(() {
        _vaAvailableCount = count;
        _mathAvailableCount = null;
        _lrAvailableCount = null;
        _itAvailableCount = null;
        if (_questionCount > count) _questionCount = count.clamp(AppConstants.minQuestions, count);
      });
    } else if (_isITSelected) {
      final count = _itPart == 'code'
          ? await _localITCodeService.getQuestionCountByDifficulty(_selectedDifficulty)
          : await _localITTheoryService.getQuestionCountByDifficulty(_selectedDifficulty);
      if (!mounted) return;
      setState(() {
        _itAvailableCount = count;
        _mathAvailableCount = null;
        _lrAvailableCount = null;
        _vaAvailableCount = null;
        if (_questionCount > count) _questionCount = count.clamp(AppConstants.minQuestions, count);
      });
    } else {
      if (mounted) setState(() {
        _mathAvailableCount = null;
        _lrAvailableCount = null;
        _vaAvailableCount = null;
        _itAvailableCount = null;
      });
    }
  }
  
  void _onSubjectChanged(String subject) {
    setState(() {
      _selectedSubject = subject;
      if (_isITSelected) _itPart = 'theory';
    });
    _loadCountsIfNeeded();
  }
  
  void _onDifficultyChanged(String level) {
    setState(() => _selectedDifficulty = level);
    _loadCountsIfNeeded();
  }

  void _onITPartChanged(String part) {
    setState(() => _itPart = part);
    _loadCountsIfNeeded();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _startQuiz() async {
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select a subject'),
            ],
          ),
          backgroundColor: AppConstants.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    
    // Validate that the selected subject is available for quiz
    if (!_isQuizAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Quiz is currently available only for Mathematics, Logical Reasoning, Verbal Ability, and Information Technology.'),
              ),
            ],
          ),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    
    setState(() => _isStarting = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) {
      setState(() => _isStarting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Please log in to start a quiz'),
            ],
          ),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    
    try {
      final success = await quizProvider.startQuiz(
        userId: authProvider.currentUser!.uid,
        subject: _selectedSubject!,
        difficulty: _selectedDifficulty,
        questionCount: _questionCount,
        itPart: _isITSelected ? _itPart : null,
      );
      
      setState(() => _isStarting = false);
      
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const QuizScreen()),
        );
      } else if (mounted && quizProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(quizProvider.errorMessage!)),
              ],
            ),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _isStarting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to start quiz: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Your Quiz'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header section
                  _buildHeaderSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Subject selection
                  _buildSectionTitle('Choose Your Subject', Icons.subject),
                  const SizedBox(height: 16),
                  
                  ...AppConstants.subjects.asMap().entries.map((entry) {
                    final index = entry.key;
                    final subject = entry.value;
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSubjectCard(subject),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Quiz only for Mathematics, Logical Reasoning, Verbal Ability, and Information Technology
                  if (!_isQuizAvailable && _selectedSubject != null) ...[
                    _buildSectionTitle('Quiz availability', Icons.info_outline),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.school_rounded, color: AppConstants.primaryColor, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Quiz is currently available only for Mathematics, Logical Reasoning, Verbal Ability, and Information Technology.',
                              style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // Difficulty and question count when an available subject is selected
                  if (_isQuizAvailable) ...[
                    if (_isITSelected) ...[
                      const SizedBox(height: 8),
                      _buildSectionTitle('Select Part', Icons.layers),
                      const SizedBox(height: 16),
                      _buildITPartSelector(),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 8),
                    _buildSectionTitle('Select Difficulty', Icons.speed),
                    const SizedBox(height: 16),
                    _buildDifficultySelector(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(
                      'Number of Questions: $_questionCount${(_mathAvailableCount ?? _lrAvailableCount ?? _vaAvailableCount ?? _itAvailableCount) != null ? ' (of ${_mathAvailableCount ?? _lrAvailableCount ?? _vaAvailableCount ?? _itAvailableCount})' : ''}',
                      Icons.format_list_numbered,
                    ),
                    const SizedBox(height: 16),
                    _buildQuestionSlider(),
                  ],
                  
                  const SizedBox(height: 48),
                  
                  AnimatedButton(
                    text: 'Start Quiz',
                    onPressed: _isQuizAvailable ? _startQuiz : null,
                    isLoading: _isStarting,
                    gradient: _isQuizAvailable ? AppConstants.primaryGradient : null,
                    icon: Icons.play_arrow_rounded,
                    isPulsing: _isQuizAvailable,
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Loading overlay
          if (_isStarting)
            const Positioned.fill(
              child: LoadingOverlay(),
            ),
        ],
      ),
    );
  }
  
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🎯',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ready to Challenge Yourself?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your quiz settings below',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppConstants.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubjectCard(String subject) {
    final isSelected = _normalizeSubject(_selectedSubject) == _normalizeSubject(subject);
    final gradient = AppConstants.getSubjectGradient(subject);
    
    return GestureDetector(
      onTap: () => _onSubjectChanged(subject),
      child: AnimatedContainer(
        duration: AppConstants.shortAnimationDuration,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppConstants.getSubjectColor(subject).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppConstants.getSubjectColor(subject).withOpacity(0.4)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 15 : 5,
              offset: Offset(0, isSelected ? 6 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              AppConstants.subjectEmojis[subject] ?? '📝',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                subject,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: AppConstants.difficultyLevels.map((level) {
          final isSelected = _selectedDifficulty == level;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onDifficultyChanged(level),
              child: AnimatedContainer(
                duration: AppConstants.shortAnimationDuration,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? _getDifficultyGradient(level) : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _getDifficultyColor(level).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  level,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  LinearGradient _getDifficultyGradient(String level) {
    switch (level) {
      case AppConstants.difficultyEasy:
        return AppConstants.successGradient;
      case AppConstants.difficultyMedium:
        return AppConstants.warningGradient;
      case AppConstants.difficultyHard:
        return AppConstants.errorGradient;
      default:
        return AppConstants.primaryGradient;
    }
  }
  
  Color _getDifficultyColor(String level) {
    switch (level) {
      case AppConstants.difficultyEasy:
        return AppConstants.successColor;
      case AppConstants.difficultyMedium:
        return AppConstants.warningColor;
      case AppConstants.difficultyHard:
        return AppConstants.errorColor;
      default:
        return AppConstants.primaryColor;
    }
  }
  
  Widget _buildQuestionSlider() {
    final maxAvailable =
        (_mathAvailableCount ?? _lrAvailableCount ?? _vaAvailableCount ?? _itAvailableCount) ??
            AppConstants.maxQuestions;
    final maxCount = maxAvailable.clamp(AppConstants.minQuestions, AppConstants.maxQuestions);
    final divisions = (maxCount - AppConstants.minQuestions).clamp(1, 50);
    final value = _questionCount.clamp(AppConstants.minQuestions, maxCount).toDouble();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.1),
            AppConstants.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppConstants.minQuestions}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$maxCount',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppConstants.primaryColor,
              inactiveTrackColor: AppConstants.primaryColor.withOpacity(0.2),
              thumbColor: AppConstants.primaryColor,
              overlayColor: AppConstants.primaryColor.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: value,
              min: AppConstants.minQuestions.toDouble(),
              max: maxCount.toDouble(),
              divisions: divisions,
              label: _questionCount.toString(),
              onChanged: (v) {
                setState(() => _questionCount = v.round().clamp(AppConstants.minQuestions, maxCount));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildITPartSelector() {
    Widget chip(String id, String label, IconData icon) {
      final isSelected = _itPart == id;
      return Expanded(
        child: GestureDetector(
          onTap: () => _onITPartChanged(id),
          child: AnimatedContainer(
            duration: AppConstants.shortAnimationDuration,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? AppConstants.accentGradient : null,
              color: isSelected ? null : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : AppConstants.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.black54),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('theory', 'Theory', Icons.menu_book_rounded),
        const SizedBox(width: 12),
        chip('code', 'Code Output', Icons.code_rounded),
      ],
    );
  }
}
