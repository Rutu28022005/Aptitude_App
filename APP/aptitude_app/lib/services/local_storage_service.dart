import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class LocalStorageService {
  static SharedPreferences? _preferences;
  
  // Initialize SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }
  
  // Login state
  static Future<bool> setLoginState(bool isLoggedIn) async {
    return await _preferences!.setBool(AppConstants.keyIsLoggedIn, isLoggedIn);
  }
  
  static bool get isLoggedIn {
    return _preferences!.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }
  
  // User ID
  static Future<bool> setUserId(String userId) async {
    return await _preferences!.setString(AppConstants.keyUserId, userId);
  }
  
  static String get userId {
    return _preferences!.getString(AppConstants.keyUserId) ?? '';
  }
  
  // User Email
  static Future<bool> setUserEmail(String email) async {
    return await _preferences!.setString(AppConstants.keyUserEmail, email);
  }
  
  static String get userEmail {
    return _preferences!.getString(AppConstants.keyUserEmail) ?? '';
  }
  
  // Streak tracking
  static Future<void> updateStreak() async {
    final lastQuizDate = _preferences!.getString(AppConstants.keyLastQuizDate);
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    
    if (lastQuizDate == null) {
      // First quiz ever
      await _preferences!.setInt(AppConstants.keyStreakCount, 1);
      await _preferences!.setString(AppConstants.keyLastQuizDate, todayString);
    } else {
      final lastDate = DateTime.tryParse(lastQuizDate);
      if (lastDate != null) {
        final difference = today.difference(lastDate).inDays;
        
        if (difference == 0) {
          // Same day, no change
          return;
        } else if (difference == 1) {
          // Consecutive day, increment streak
          final currentStreak = streakCount;
          await _preferences!.setInt(AppConstants.keyStreakCount, currentStreak + 1);
          await _preferences!.setString(AppConstants.keyLastQuizDate, todayString);
        } else {
          // Streak broken, reset to 1
          await _preferences!.setInt(AppConstants.keyStreakCount, 1);
          await _preferences!.setString(AppConstants.keyLastQuizDate, todayString);
        }
      }
    }
  }
  
  static int get streakCount {
    return _preferences!.getInt(AppConstants.keyStreakCount) ?? 0;
  }
  
  // Clear all data (logout)
  static Future<void> clearAll() async {
    await _preferences!.clear();
  }
}
