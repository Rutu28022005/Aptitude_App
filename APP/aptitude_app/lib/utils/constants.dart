import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Aptitude Pro';
  static const String appVersion = '1.0.0';
  
  // Subjects
  static const String mathSubject = 'Mathematics/Quants';
  static const String reasoningSubject = 'Logical Reasoning';
  static const String varcSubject = 'Verbal Ability';
  static const String itSubject = 'Information Technology';
  
  static const List<String> subjects = [
    mathSubject,
    reasoningSubject,
    varcSubject,
    itSubject,
  ];
  
  // Subject Icons (emoji)
  static const Map<String, String> subjectEmojis = {
    mathSubject: '🔢',
    reasoningSubject: '🧩',
    varcSubject: '📚',
    itSubject: '💻',
  };
  
  // Quiz Settings
  static const int defaultQuestionCount = 10;
  static const int questionTimerSeconds = 30;
  static const int minQuestions = 5;
  static const int maxQuestions = 50;
  
  // Difficulty Levels
  static const String difficultyEasy = 'Easy';
  static const String difficultyMedium = 'Medium';
  static const String difficultyHard = 'Hard';
  
  static const List<String> difficultyLevels = [
    difficultyEasy,
    difficultyMedium,
    difficultyHard,
  ];
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String quizResultsCollection = 'quizResults';
  static const String userProfileSubCollection = 'profile';
  
  // SharedPreferences Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyLastQuizDate = 'last_quiz_date';
  static const String keyStreakCount = 'streak_count';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyNotificationHour = 'notification_hour';
  static const String keyNotificationMinute = 'notification_minute';
  
  // Performance Thresholds
  static const double excellentThreshold = 90.0;
  static const double goodThreshold = 75.0;
  static const double averageThreshold = 60.0;
  
  // Vibrant Color Palette
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple
  static const Color accentColor = Color(0xFF06B6D4); // Cyan
  static const Color successColor = Color(0xFF10B981); // Green
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red
  
  // Additional vibrant colors for UI
  static const Color vibrantPink = Color(0xFFEC4899);
  static const Color vibrantBlue = Color(0xFF3B82F6);
  static const Color vibrantTeal = Color(0xFF14B8A6);
  static const Color vibrantOrange = Color(0xFFF97316);
  static const Color vibrantRose = Color(0xFFFB7185);
  
  // Subject Chart Colors
  static const Color mathColor = Color(0xFF6366F1); // Indigo
  static const Color reasoningColor = Color(0xFF8B5CF6); // Purple
  static const Color varcColor = Color(0xFF06B6D4); // Cyan
  static const Color itColor = Color(0xFF10B981); // Green
  
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient getSubjectGradient(String subject) {
    switch (subject) {
      case mathSubject:
        return const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case reasoningSubject:
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case varcSubject:
        return const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case itSubject:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return primaryGradient;
    }
  }
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  static const Duration extraLongAnimationDuration = Duration(milliseconds: 800);
  
  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  static Color getSubjectColor(String subject) {
    switch (subject) {
      case mathSubject:
        return mathColor;
      case reasoningSubject:
        return reasoningColor;
      case varcSubject:
        return varcColor;
      case itSubject:
        return itColor;
      default:
        return primaryColor;
    }
  }
  
  // Motivational Messages
  static String getMotivationalMessage(double accuracy) {
    if (accuracy >= excellentThreshold) {
      return '🎉 Outstanding! You\'re crushing it!';
    } else if (accuracy >= goodThreshold) {
      return '👏 Great job! Keep up the good work!';
    } else if (accuracy >= averageThreshold) {
      return '💪 Good effort! Practice more to improve!';
    } else {
      return '📚 Keep practicing! Every attempt makes you better!';
    }
  }
  
  // Celebration Messages
  static const List<String> excellentMessages = [
    '🌟 Absolutely brilliant!',
    '🚀 You\'re on fire!',
    '⭐ Phenomenal performance!',
    '🎯 Bulls-eye! Perfect shot!',
    '👑 You\'re the champion!',
  ];
  
  static const List<String> goodMessages = [
    '✨ Impressive work!',
    '🎊 Well done!',
    '💫 Keep shining!',
    '🌈 Beautiful job!',
    '🎨 Masterful!',
  ];
  
  static const List<String> averageMessages = [
    '💪 Good try! Keep going!',
    '🌱 You\'re growing!',
    '⚡ Building momentum!',
    '🎯 Getting better!',
    '🔥 Keep the fire burning!',
  ];
  
  static const List<String> needsWorkMessages = [
    '📖 Practice makes perfect!',
    '🌟 Every star starts small!',
    '💎 Diamonds need pressure!',
    '🎓 Learning is a journey!',
    '🚀 You\'ll get there!',
  ];
  
  static String getRandomCelebrationMessage(double score) {
    final random = (DateTime.now().millisecondsSinceEpoch % 5);
    if (score >= excellentThreshold) {
      return excellentMessages[random];
    } else if (score >= goodThreshold) {
      return goodMessages[random];
    } else if (score >= averageThreshold) {
      return averageMessages[random];
    } else {
      return needsWorkMessages[random];
    }
  }
  
  // Loading Messages
  static const List<String> loadingMessages = [
    '🎯 Generating questions...',
    '🧠 Preparing your challenge...',
    '✨ Creating unique questions...',
    '🚀 Almost ready...',
    '💫 Crafting your quiz...',
  ];
  
  static String getRandomLoadingMessage() {
    final random = DateTime.now().millisecondsSinceEpoch % loadingMessages.length;
    return loadingMessages[random];
  }
}
