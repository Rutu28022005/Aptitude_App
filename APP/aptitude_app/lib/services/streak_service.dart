import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class StreakService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Update user streak when they complete a quiz.
  ///
  /// Returns the updated [UserModel]. The caller MUST replace their local
  /// user reference with the returned value so the UI reflects the new streak.
  ///
  /// Example usage after quiz completion:
  /// ```dart
  /// final streakService = StreakService();
  /// _currentUser = await streakService.updateStreak(_currentUser);
  /// // Now notify your state management (setState / notifyListeners / emit)
  /// ```
  Future<UserModel> updateStreak(UserModel user) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Normalize last practice date to start of day for comparison
    final lastPractice = user.lastPracticeDate != null
        ? DateTime(
      user.lastPracticeDate!.year,
      user.lastPracticeDate!.month,
      user.lastPracticeDate!.day,
    )
        : null;

    int newCurrentStreak = user.currentStreak;
    int newLongestStreak = user.longestStreak;

    if (lastPractice == null) {
      // First time ever practicing
      newCurrentStreak = 1;
      newLongestStreak = 1;
    } else if (lastPractice == today) {
      // Already practiced today — streak unchanged, but still return user
      // so callers get a consistent result without needing to special-case this.
      return user;
    } else {
      final daysDifference = today.difference(lastPractice).inDays;

      if (daysDifference == 1) {
        // Practiced on consecutive days — extend streak
        newCurrentStreak = user.currentStreak + 1;
        if (newCurrentStreak > user.longestStreak) {
          newLongestStreak = newCurrentStreak;
        }
      } else {
        // Gap of 2+ days — streak broken, reset to 1
        newCurrentStreak = 1;
        // longestStreak is never reduced
      }
    }

    // Build the updated model first so we can return it even if the save fails
    final updatedUser = user.copyWith(
      lastPracticeDate: now,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
    );

    // Persist via FirestoreService so all writes go through one service
    try {
      await _firestoreService.saveUserProfile(updatedUser);
    } catch (e) {
      // Log but do not rethrow — the in-memory model is still correct and the
      // UI should update. A subsequent app launch will re-read Firestore.
      print('StreakService: failed to persist streak update: $e');
    }

    return updatedUser;
  }

  /// Convenience method: fetch the latest user data from Firestore and then
  /// run [updateStreak] on it. Useful when the local model may be stale.
  Future<UserModel?> updateStreakFromFirestore(String userId) async {
    final freshUser = await _firestoreService.getUserProfile(userId);
    if (freshUser == null) return null;
    return updateStreak(freshUser);
  }

  /// Returns `true` if the streak is still alive (practiced today or yesterday).
  bool isStreakActive(UserModel user) {
    if (user.lastPracticeDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPractice = DateTime(
      user.lastPracticeDate!.year,
      user.lastPracticeDate!.month,
      user.lastPracticeDate!.day,
    );

    return today.difference(lastPractice).inDays <= 1;
  }

  /// Returns a motivational message based on the current streak count.
  String getStreakMessage(int streak) {
    if (streak == 0) {
      return 'Start your learning streak today! 🚀';
    } else if (streak == 1) {
      return 'Great start! Keep it up! 💪';
    } else if (streak < 7) {
      return '$streak days strong! You\'re building a habit! 🔥';
    } else if (streak < 30) {
      return 'Amazing! $streak day streak! You\'re unstoppable! 🌟';
    } else if (streak < 100) {
      return 'Incredible! $streak days! You\'re a champion! 🏆';
    } else {
      return 'Legendary! $streak day streak! 👑';
    }
  }
}