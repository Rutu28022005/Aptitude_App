import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/result_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===== USER PROFILE =====

  /// Create or overwrite a user profile document.
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw 'Failed to save user profile: $e';
    }
  }

  /// Fetch a user profile. Returns `null` if the document does not exist.
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user profile: $e';
    }
  }

  // ===== QUIZ RESULTS =====

  /// Persist a completed quiz result.
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      await _db
          .collection('users')
          .doc(result.userId)
          .collection('quizResults')
          .doc(result.id)
          .set(result.toMap());
    } catch (e) {
      throw 'Failed to save quiz result: $e';
    }
  }

  /// Fetch all quiz results for a user, newest first.
  Future<List<QuizResult>> getUserQuizResults(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('quizResults')
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => QuizResult.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch quiz results: $e';
    }
  }

  /// Fetch the most recent [limit] quiz results for a user.
  Future<List<QuizResult>> getRecentQuizResults(
      String userId, int limit) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('quizResults')
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => QuizResult.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch recent quiz results: $e';
    }
  }

  /// Fetch a single quiz result by its ID. Returns `null` if not found.
  Future<QuizResult?> getQuizResult(String userId, String quizId) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('quizResults')
          .doc(quizId)
          .get();

      if (doc.exists) {
        return QuizResult.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch quiz result: $e';
    }
  }

  /// Returns the accuracy of the most recent quiz, or `null` if none exist.
  Future<double?> getLastQuizScore(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('quizResults')
          .orderBy('completedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return QuizResult.fromMap(
            snapshot.docs.first.data(), snapshot.docs.first.id)
            .accuracy;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Compute average accuracy across all quiz results for a user.
  Future<double> getOverallAccuracy(String userId) async {
    try {
      final results = await getUserQuizResults(userId);
      if (results.isEmpty) return 0.0;

      final total = results.fold<double>(0, (sum, r) => sum + r.accuracy);
      return total / results.length;
    } catch (e) {
      return 0.0;
    }
  }

  // ===== QUESTION ATTEMPT METADATA (24-hour retention) =====

  /// Save lightweight metadata about a single question attempt.
  /// Uses merge so re-attempts update the existing document in place.
  Future<void> saveQuestionAttempt({
    required String userId,
    required String questionHash,
    required String subject,
    required String difficulty,
    required bool correct,
    required int timeTaken,
    required DateTime attemptedAt,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('questionAttempts')
          .doc(questionHash)
          .set({
        'questionHash': questionHash,
        'subject': subject,
        'difficulty': difficulty,
        'correct': correct,
        'timeTaken': timeTaken,
        'attemptedAt': attemptedAt.toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Failed to save question attempt: $e');
    }
  }

  /// Returns all question hashes the user has ever attempted (for dedup).
  Future<List<String>> getUserAttemptedQuestionHashes(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('questionAttempts')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['questionHash'] as String)
          .toList();
    } catch (e) {
      print('Failed to fetch attempted question hashes: $e');
      return [];
    }
  }

  // ===== QUIZ QUESTIONS (temporary, 24-hour review window) =====

  /// Store the full question set for a completed quiz so users can review it.
  Future<void> saveQuizQuestions({
    required String userId,
    required String quizId,
    required List<Map<String, dynamic>> questions,
    required Map<int, int> userAnswers,
    required DateTime expiresAt,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('quizQuestions')
          .doc(quizId)
          .set({
        'quizId': quizId,
        'questions': questions,
        'userAnswers': userAnswers.map((k, v) => MapEntry(k.toString(), v)),
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      });
    } catch (e) {
      print('Failed to save quiz questions: $e');
    }
  }

  /// Retrieve quiz questions if they haven't expired yet.
  /// Automatically deletes the document if it has expired.
  Future<Map<String, dynamic>?> getQuizQuestions({
    required String userId,
    required String quizId,
  }) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('quizQuestions')
          .doc(quizId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final expiresAt = DateTime.parse(data['expiresAt'] as String);

      if (DateTime.now().isAfter(expiresAt)) {
        await doc.reference.delete();
        return null;
      }

      final questions = List<Map<String, dynamic>>.from(data['questions'] as List);
      final uaRaw = data['userAnswers'] as Map? ?? {};
      final userAnswers = uaRaw.map<int, int>(
        (k, v) => MapEntry(int.parse(k.toString()), (v as num).toInt()),
      );

      return {
        'questions': questions,
        'userAnswers': userAnswers,
      };
    } catch (e) {
      print('Failed to fetch quiz questions: $e');
      return null;
    }
  }

  // ===== QUESTION HASHES (permanent deduplication) =====

  /// Merge [hashes] into the per-subject/difficulty hash document.
  /// Uses [FieldValue.arrayUnion] so duplicates are never stored.
  Future<void> saveQuestionHashes(
      String userId,
      List<String> hashes,
      String subject,
      String difficulty,
      ) async {
    if (hashes.isEmpty) return;
    try {
      final docId = _hashDocId(subject, difficulty);
      await _db
          .collection('users')
          .doc(userId)
          .collection('question_hashes')
          .doc(docId)
          .set({
        'subject': subject,
        'difficulty': difficulty,
        'hashes': FieldValue.arrayUnion(hashes),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Failed to save question hashes: $e');
    }
  }

  /// Retrieve all stored hashes for a subject + difficulty combination.
  Future<List<String>> getQuestionHashes(
      String userId,
      String subject,
      String difficulty,
      ) async {
    try {
      final docId = _hashDocId(subject, difficulty);
      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('question_hashes')
          .doc(docId)
          .get();

      if (!doc.exists) return [];
      final hashes = doc.data()!['hashes'];
      if (hashes == null) return [];
      return List<String>.from(hashes as List);
    } catch (e) {
      print('Failed to fetch question hashes: $e');
      return [];
    }
  }

  /// Total unique question hashes stored across all subjects (for analytics).
  Future<int> getTotalQuestionHashCount(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('question_hashes')
          .get();

      return snapshot.docs.fold<int>(0, (total, doc) {
        final hashes = doc.data()['hashes'];
        return total + (hashes != null ? (hashes as List).length : 0);
      });
    } catch (e) {
      return 0;
    }
  }

  /// Stable Firestore document ID derived from subject + difficulty.
  String _hashDocId(String subject, String difficulty) {
    final safe = subject
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return '${safe}_${difficulty.toLowerCase()}';
  }

  // ===== CLEANUP =====

  /// Delete any quiz question documents whose [expiresAt] has passed.
  /// Call this on app launch to keep storage tidy.
  Future<void> cleanupExpiredQuestions(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('quizQuestions')
          .get();

      final now = DateTime.now();
      final deletions = <Future<void>>[];

      for (final doc in snapshot.docs) {
        final expiresAtRaw = doc.data()['expiresAt'];
        if (expiresAtRaw != null) {
          final expiresAt = DateTime.parse(expiresAtRaw as String);
          if (now.isAfter(expiresAt)) {
            deletions.add(doc.reference.delete());
          }
        }
      }

      await Future.wait(deletions);
    } catch (e) {
      print('Failed to cleanup expired questions: $e');
    }
  }
}