import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';
import '../config/api_config.dart';
import 'question_hash_service.dart';
import 'firestore_service.dart';

class AIQuestionService {
  static const int maxAttempts = 5;

  final FirestoreService _firestoreService;

  AIQuestionService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  static const Map<String, String> _subjectPrompts = {
    'Mathematics/Quants':
    'Mathematics and Quantitative Aptitude (Arithmetic, Algebra, Geometry, '
        'Time & Work, Speed & Distance, Profit & Loss, Percentages, Ratios, '
        'Number Series)',
    'Logical Reasoning':
    'Logical Reasoning (Pattern Recognition, Series Completion, '
        'Coding-Decoding, Blood Relations, Direction Sense, Syllogisms, '
        'Puzzles, Seating Arrangements)',
    'Verbal Ability':
    'Verbal Ability and Reading Comprehension (Vocabulary, '
        'Synonyms/Antonyms, Sentence Correction, Para Jumbles, '
        'Fill in the Blanks, Reading Comprehension, Grammar)',
    'Information Technology':
    'Information Technology (Machine Learning, Full Stack Development, '
        'DBMS, Data Structures & Algorithms, C++, Java, Operating Systems)',
  };

  Future<List<Question>> fetchUniqueQuestions({
    required String userId,
    required String subject,
    required String difficulty,
    required int count,
  }) async {
    final storedHashes = await _firestoreService.getQuestionHashes(
      userId,
      subject,
      difficulty,
    );

    debugPrint(
        '🔍 AIQuestionService: ${storedHashes.length} stored hashes for $subject/$difficulty');

    final sessionHashes = <String>{...storedHashes};
    final collected = <Question>[];

    int attempt = 0;
    int consecutiveFailures = 0; // ← NEW: track back-to-back API failures

    while (collected.length < count && attempt < maxAttempts) {
      attempt++;
      final needed = count - collected.length;

      debugPrint(
          '🔄 Attempt $attempt/$maxAttempts — need $needed more unique questions');

      try {
        final requestId = _buildRequestId(userId);
        final batch = await _callOpenAI(
          userId: userId,
          requestId: requestId,
          subject: subject,
          difficulty: difficulty,
          count: needed,
          excludeHashes: sessionHashes.toList(),
        );

        consecutiveFailures = 0; // reset on success
        int addedThisRound = 0;
        for (final q in batch) {
          if (!sessionHashes.contains(q.questionHash)) {
            sessionHashes.add(q.questionHash);
            collected.add(q);
            addedThisRound++;
          } else {
            debugPrint(
                '♻️  Duplicate discarded: ${q.questionHash.substring(0, 8)}…');
          }
        }
        debugPrint('✅ Attempt $attempt: added $addedThisRound unique questions '
            '(total: ${collected.length}/$count)');
      } catch (e) {
        debugPrint('❌ Attempt $attempt failed: $e');
        consecutiveFailures++;

        if (e.toString().contains('Invalid API key') ||
            e.toString().contains('401')) {
          rethrow;
        }

        // ← NEW: stop retrying after 2 consecutive failures and use fallback
        if (consecutiveFailures >= 2) {
          debugPrint(
              '⚠️ API failing consistently — switching to fallback questions');
          break;
        }
      }
    }

    // ← NEW: fill any remaining slots with fallback questions
    if (collected.length < count) {
      debugPrint(
          '⚠️ Only ${collected.length}/$count from API. '
              'Filling ${count - collected.length} with fallback questions.');

      final fallback = _generateFallbackQuestions(
        subject,
        difficulty,
        count - collected.length,
        existingHashes: sessionHashes,
      );

      for (final q in fallback) {
        if (!sessionHashes.contains(q.questionHash)) {
          sessionHashes.add(q.questionHash);
          collected.add(q);
        }
      }
    }

    if (collected.isNotEmpty) {
      final newHashes = collected.map((q) => q.questionHash).toList();
      await _firestoreService.saveQuestionHashes(
        userId,
        newHashes,
        subject,
        difficulty,
      );
      debugPrint(
          '💾 Saved ${newHashes.length} new question hashes to Firestore');
    }

    return collected;
  }

  String _buildRequestId(String userId) {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final rng = Random.secure();
    final randomHex = List.generate(4, (_) => rng.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${userId}_${timestamp}_$randomHex';
  }

  Future<List<Question>> _callOpenAI({
    required String userId,
    required String requestId,
    required String subject,
    required String difficulty,
    required int count,
    required List<String> excludeHashes,
  }) async {
    final subjectDescription =
        _subjectPrompts[subject] ?? _subjectPrompts['Mathematics/Quants']!;
    final randomSeed =
        DateTime.now().millisecondsSinceEpoch + Random().nextInt(100000);
    final timestamp = DateTime.now().toUtc().toIso8601String();

    final exclusionHint = excludeHashes.isNotEmpty
        ? '\n\nCRITICAL: The user has already seen ${excludeHashes.length} questions. '
        'You MUST generate completely different questions. '
        'Excluded question fingerprints (SHA-256): ${excludeHashes.take(20).join(", ")}${excludeHashes.length > 20 ? "... (${excludeHashes.length - 20} more)" : ""}'
        : '';

    final requestBody = {
      'user_id': userId,
      'request_id': requestId,
      'subject': subjectDescription,
      'difficulty': difficulty,
      'count': count,
      'exclude_hashes': excludeHashes.take(50).toList(),
      'instructions':
      'Generate unique, never-repeated multiple-choice aptitude questions '
          'appropriate for college placement tests. Each item must have: '
          'id, question, 4 options, correct_option_index (0-3), explanation. '
          'Return ONLY valid JSON.',
    };

    final systemPrompt =
        'You are an expert in creating aptitude test questions for college placement exams. '
        'Generate $count $difficulty level questions on: $subjectDescription. '
        'Each question must be MCQ format with exactly 4 options. '
        'IMPORTANT: Generate completely original questions, never repeat previous ones.$exclusionHint';

    final userPrompt =
    '''Generate $count unique multiple-choice aptitude questions in this EXACT JSON format (no additional text):
{
  "questions": [
    {
      "question": "Question text here?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctIndex": 0,
      "explanation": "Brief explanation of the correct answer"
    }
  ]
}

STRICT REQUIREMENTS:
- Difficulty: $difficulty
- Subject: $subjectDescription
- Each question must have exactly 4 options
- correctIndex is 0-3 (0=A, 1=B, 2=C, 3=D)
- Test conceptual understanding, not just memory
- Completely original — never repeat previously seen questions

Request metadata (use for variety):
- request_id: $requestId
- timestamp: $timestamp
- random_seed: $randomSeed
- request_body: ${jsonEncode(requestBody)}
''';

    final response = await http.post(
      Uri.parse(ApiConfig.openAiApiEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
      },
      body: jsonEncode({
        'model': ApiConfig.openAiModel,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.95,
        'max_tokens': 3000,
        'seed': randomSeed,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;

      // ← CHANGED: more robust cleaning — strip markdown fences first,
      // then find the first '{' in case the model added preamble text.
      String cleaned = content
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final jsonStart = cleaned.indexOf('{');
      if (jsonStart > 0) {
        cleaned = cleaned.substring(jsonStart);
      }

      // ← CHANGED: wrap JSON decode in try/catch and throw a retryable error
      // instead of crashing the whole quiz flow.
      Map<String, dynamic> questionsJson;
      try {
        questionsJson = jsonDecode(cleaned) as Map<String, dynamic>;
      } on FormatException catch (e) {
        debugPrint('❌ JSON parse error: $e\nRaw: $content');
        throw 'Invalid JSON from API — will retry';
      }

      // ← CHANGED: guard against empty list before mapping
      final questionsList = questionsJson['questions'] as List? ?? [];
      if (questionsList.isEmpty) {
        throw 'API returned empty questions list — will retry';
      }

      final now = DateTime.now();
      return questionsList.asMap().entries.map((entry) {
        final index = entry.key;
        final q = entry.value as Map<String, dynamic>;
        final questionText = (q['question'] ?? '').toString();
        final questionHash = QuestionHashService.generateHash(questionText);

        return Question(
          id: '${QuestionHashService.generateAttemptId()}_$index',
          subject: subject,
          questionText: questionText,
          options: List<String>.from(q['options'] ?? []),
          correctAnswerIndex: (q['correctIndex'] ?? 0) as int,
          difficulty: difficulty,
          timeLimitSeconds: 30,
          explanation: (q['explanation'] ?? '').toString(),
          questionHash: questionHash,
          generatedAt: now,
          expiresAt: now.add(const Duration(hours: 24)),
          randomSeed: randomSeed,
        );
      }).toList();
    } else if (response.statusCode == 401) {
      throw 'Invalid API key. Please check your OpenAI API configuration.';
    } else if (response.statusCode == 429) {
      throw 'API rate limit exceeded. Please try again in a few moments.';
    } else {
      throw 'OpenAI API error ${response.statusCode}: ${response.body}';
    }
  }

  // ── Fallback question bank ────────────────────────────────────────────────
  // ← NEW: mirrors ai_service.dart so the quiz always has questions even
  // when the API is unavailable or returning malformed responses.

  List<Question> _generateFallbackQuestions(
      String subject,
      String difficulty,
      int count, {
        Set<String> existingHashes = const {},
      }) {
    final bank = _getFallbackBank(subject);
    final questions = <Question>[];
    final now = DateTime.now();

    for (int i = 0; i < bank.length && questions.length < count; i++) {
      final data = bank[i];
      final questionText = data['question'] as String;
      // Append index to differentiate hashes from the same base question
      // when the bank is smaller than the requested count.
      final hash = QuestionHashService.generateHash('$questionText\_fallback_$i');

      if (existingHashes.contains(hash)) continue;

      questions.add(Question(
        id: '${QuestionHashService.generateAttemptId()}_fallback_$i',
        subject: subject,
        questionText: questionText,
        options: List<String>.from(data['options'] as List),
        correctAnswerIndex: data['correctIndex'] as int,
        difficulty: difficulty,
        timeLimitSeconds: 30,
        explanation: (data['explanation'] ?? '') as String,
        questionHash: hash,
        generatedAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
        randomSeed: now.millisecondsSinceEpoch + i,
      ));
    }

    return questions;
  }

  List<Map<String, dynamic>> _getFallbackBank(String subject) {
    if (subject.contains('Mathematics') || subject.contains('Quants')) {
      return _mathQuestions;
    } else if (subject.contains('Logical')) {
      return _reasoningQuestions;
    } else if (subject.contains('Verbal Ability')) {
      return _varcQuestions;
    } else if (subject.contains('Information Technology')) {
      return _itQuestions;
    }
    return _mathQuestions;
  }

  final List<Map<String, dynamic>> _mathQuestions = [
    {'question': 'If x + y = 10 and x - y = 2, what is the value of x?', 'options': ['4', '6', '8', '10'], 'correctIndex': 1, 'explanation': 'Add both equations: 2x = 12, so x = 6'},
    {'question': 'What is 15% of 200?', 'options': ['25', '30', '35', '40'], 'correctIndex': 1, 'explanation': '15% of 200 = (15/100) × 200 = 30'},
    {'question': 'A train travels 60 km in 45 minutes. What is its speed in km/h?', 'options': ['60', '70', '80', '90'], 'correctIndex': 2, 'explanation': 'Speed = Distance/Time = 60/(45/60) = 80 km/h'},
    {'question': 'If the ratio of boys to girls is 3:2 and there are 15 boys, how many girls are there?', 'options': ['8', '10', '12', '15'], 'correctIndex': 1, 'explanation': 'If 3 parts = 15, then 1 part = 5. Girls = 2 parts = 10'},
    {'question': 'What is the area of a rectangle with length 12 cm and width 5 cm?', 'options': ['50 cm²', '55 cm²', '60 cm²', '65 cm²'], 'correctIndex': 2, 'explanation': 'Area = length × width = 12 × 5 = 60 cm²'},
  ];

  final List<Map<String, dynamic>> _reasoningQuestions = [
    {'question': 'Complete the series: 2, 6, 12, 20, 30, ?', 'options': ['40', '42', '44', '46'], 'correctIndex': 1, 'explanation': 'Pattern: +4, +6, +8, +10, +12. Next is 30+12=42'},
    {'question': 'If all roses are flowers and some flowers fade quickly, which statement must be true?', 'options': ['All roses fade quickly', 'Some roses are not flowers', 'Some roses may fade quickly', 'No roses fade quickly'], 'correctIndex': 2, 'explanation': 'Since all roses are flowers and some flowers fade quickly, it\'s possible some roses fade quickly'},
    {'question': 'What comes next: A, C, F, J, O, ?', 'options': ['S', 'T', 'U', 'V'], 'correctIndex': 2, 'explanation': 'Pattern: +2, +3, +4, +5, +6. O+6=U'},
    {'question': 'In a certain code, PLANT is written as QMBOU. How is WATER written?', 'options': ['XBUFS', 'XBTES', 'WBUFS', 'YBUFS'], 'correctIndex': 0, 'explanation': 'Each letter is shifted by +1. W→X, A→B, T→U, E→F, R→S'},
    {'question': 'If South-East becomes North and North-East becomes West, what does South become?', 'options': ['North-East', 'North-West', 'South-West', 'East'], 'correctIndex': 0, 'explanation': 'Pattern shows 90° anti-clockwise rotation. South becomes North-East'},
  ];

  final List<Map<String, dynamic>> _varcQuestions = [
    {'question': 'Choose the word most similar in meaning to ABUNDANT:', 'options': ['Scarce', 'Plentiful', 'Limited', 'Rare'], 'correctIndex': 1, 'explanation': 'Abundant means plentiful or available in large quantities'},
    {'question': 'Choose the correct sentence:', 'options': ['Neither of the students have completed the assignment.', 'Neither of the students has completed the assignment.', 'Neither of the student has completed the assignment.', 'Neither of the student have completed the assignment.'], 'correctIndex': 1, 'explanation': '"Neither" is singular and requires "has". "Students" must be plural after "of the"'},
    {'question': 'Choose the antonym of METICULOUS:', 'options': ['Careful', 'Careless', 'Detailed', 'Thorough'], 'correctIndex': 1, 'explanation': 'Meticulous means very careful and precise, opposite is careless'},
    {'question': 'Fill in the blank: The manager was known for his _____ approach to problem-solving.', 'options': ['pragmatic', 'theoretical', 'impractical', 'abstract'], 'correctIndex': 0, 'explanation': 'Pragmatic means practical and focused on results'},
    {'question': 'Identify the error: "The committee have decided to postpone the meeting."', 'options': ['have decided', 'to postpone', 'the meeting', 'No error'], 'correctIndex': 0, 'explanation': '"Committee" is a collective noun and should use singular verb "has decided"'},
  ];

  final List<Map<String, dynamic>> _itQuestions = [
    {'question': 'Which data structure uses LIFO (Last In First Out) principle?', 'options': ['Queue', 'Stack', 'Array', 'Linked List'], 'correctIndex': 1, 'explanation': 'Stack follows LIFO - the last element added is the first one removed'},
    {'question': 'What is the time complexity of binary search in a sorted array?', 'options': ['O(n)', 'O(n²)', 'O(log n)', 'O(1)'], 'correctIndex': 2, 'explanation': 'Binary search divides search space in half each time, giving O(log n) complexity'},
    {'question': 'In SQL, which command is used to remove all rows from a table?', 'options': ['DELETE', 'DROP', 'TRUNCATE', 'REMOVE'], 'correctIndex': 2, 'explanation': 'TRUNCATE removes all rows from a table efficiently without logging individual deletions'},
    {'question': 'What does "this" keyword refer to in Java?', 'options': ['Parent class', 'Current object', 'Static method', 'Constructor'], 'correctIndex': 1, 'explanation': '"this" refers to the current instance of the class'},
    {'question': 'Which scheduling algorithm can cause starvation?', 'options': ['Round Robin', 'FCFS', 'Priority Scheduling', 'SJF'], 'correctIndex': 2, 'explanation': 'Priority Scheduling can cause starvation when high-priority processes keep arriving'},
  ];
}