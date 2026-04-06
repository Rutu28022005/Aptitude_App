import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Service for generating and managing question hashes
/// Used to prevent question repetition across sessions
class QuestionHashService {
  /// Generate SHA-256 hash from question text
  /// This creates a unique identifier for each question
  static String generateHash(String questionText) {
    // Normalize the question text (lowercase, trim whitespace)
    final normalized = questionText.toLowerCase().trim();
    
    // Convert to bytes and generate hash
    final bytes = utf8.encode(normalized);
    final hash = sha256.convert(bytes);
    
    return hash.toString();
  }
  
  /// Generate a unique ID for a question attempt
  /// Format: timestamp_randomComponent
  static String generateAttemptId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return '${timestamp}_$random';
  }
  
  /// Check if a question text has been seen before
  /// by comparing its hash against a list of known hashes
  static bool isDuplicate(String questionText, List<String> existingHashes) {
    final hash = generateHash(questionText);
    return existingHashes.contains(hash);
  }
  
  /// Generate multiple hashes from a list of question texts
  static List<String> generateBatchHashes(List<String> questionTexts) {
    return questionTexts.map((text) => generateHash(text)).toList();
  }
}
