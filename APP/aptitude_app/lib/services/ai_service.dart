import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';
import '../config/api_config.dart';
import 'question_hash_service.dart';

class AIService {
  // System prompts for different subjects
  static const Map<String, String> _subjectPrompts = {
    'Mathematics/Quants': '''You are an expert in creating aptitude test questions for college placement exams. 
Generate {count} {difficulty} level Mathematics and Quantitative Aptitude questions suitable for campus placements.
Focus on topics like: Arithmetic, Algebra, Geometry, Time & Work, Speed & Distance, Profit & Loss, Percentages, Ratios, Number Series, etc.
Each question should be MCQ format with exactly 4 options.''',
    
    'Logical Reasoning': '''You are an expert in creating aptitude test questions for college placement exams.
Generate {count} {difficulty} level Logical Reasoning questions suitable for campus placements.
Focus on topics like: Pattern Recognition, Series Completion, Coding-Decoding, Blood Relations, Direction Sense, Syllogisms, Puzzles, Seating Arrangements, etc.
Each question should be MCQ format with exactly 4 options.''',
    
    'Verbal Ability': '''You are an expert in creating aptitude test questions for college placement exams.
Generate {count} {difficulty} level Verbal Ability and Reading Comprehension questions suitable for campus placements.
Focus on topics like: Vocabulary, Synonyms/Antonyms, Sentence Correction, Para Jumbles, Fill in the Blanks, Reading Comprehension, Grammar, etc.
Each question should be MCQ format with exactly 4 options.''',
    
    'Information Technology': '''You are an expert in creating technical aptitude questions for IT/CS college students preparing for placements.
Generate {count} {difficulty} level Information Technology questions covering multiple domains.
Focus on topics from: Machine Learning (basics, algorithms, concepts), Full Stack Development (React, Node.js, databases, REST APIs), 
Database Management Systems (SQL, normalization, transactions, indexing), Data Structures & Algorithms (arrays, linked lists, trees, graphs, sorting, searching),
C++ (OOP, STL, pointers, classes), C (pointers, memory management, structures), Java (OOP, collections, multithreading), 
Operating Systems (processes, threads, scheduling, memory management, deadlocks).
Each question should be MCQ format with exactly 4 options and test practical understanding.'''
  };

  // Generate questions using OpenAI API
  Future<List<Question>> generateQuestions({
    required String subject,
    required String difficulty,
    required int count,
    List<String>? excludedHashes, // Hashes of questions user has already seen
  }) async {
    try {
      // Generate random seed for uniqueness
      final randomSeed = DateTime.now().millisecondsSinceEpoch + Random().nextInt(100000);
      final timestamp = DateTime.now().toIso8601String();
      
      // Get the appropriate system prompt
      final systemPrompt = _subjectPrompts[subject] ?? _subjectPrompts['Mathematics/Quants']!;
      final prompt = systemPrompt
          .replaceAll('{count}', count.toString())
          .replaceAll('{difficulty}', difficulty);

      // Create exclusion hint if there are previously seen questions
      final exclusionHint = excludedHashes != null && excludedHashes.isNotEmpty
          ? '\n\nIMPORTANT: Ensure questions are completely different from previously generated ones. User has already seen ${excludedHashes.length} questions on this topic.'
          : '';

      // Create the API request
      final response = await http.post(
        Uri.parse(ApiConfig.openAiApiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
        },
        body: jsonEncode({
          'model': ApiConfig.openAiModel,
          'messages': [
            {
              'role': 'system',
              'content': prompt,
            },
            {
              'role': 'user',
              'content': '''Generate $count unique, never-repeated multiple-choice aptitude questions in the following JSON format ONLY (no additional text):
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
- Ensure complete originality - questions must be unique and varied
- Difficulty level: $difficulty
- Suitable for college students preparing for placements
- Each question must have exactly 4 options
- correctIndex is 0-3 (0=A, 1=B, 2=C, 3=D)
- Test conceptual understanding, not just memory
- Avoid similar patterns or repeated concepts$exclusionHint

Generation Context:
- Timestamp: $timestamp
- Random Seed: $randomSeed
- Use this seed to ensure variety
'''
            }
          ],
          'temperature': 0.9, // Higher temperature for more variety
          'max_tokens': 2000,
          'seed': randomSeed, // Pass seed to OpenAI for deterministic uniqueness
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Parse the JSON response
        final questionsJson = jsonDecode(content);
        final questionsList = questionsJson['questions'] as List;
        
        // Convert to Question objects with hashes
        final now = DateTime.now();
        final expiryTime = now.add(Duration(hours: 24)); // 24-hour retention
        
        return questionsList.asMap().entries.map((entry) {
          final index = entry.key;
          final q = entry.value;
          final questionText = q['question'];
          
          // Generate hash for this question
          final questionHash = QuestionHashService.generateHash(questionText);
          
          return Question(
            id: QuestionHashService.generateAttemptId() + '_$index',
            subject: subject,
            questionText: questionText,
            options: List<String>.from(q['options']),
            correctAnswerIndex: q['correctIndex'],
            difficulty: difficulty,
            timeLimitSeconds: 30,
            explanation: q['explanation'] ?? '',
            questionHash: questionHash,
            generatedAt: now,
            expiresAt: expiryTime,
            randomSeed: randomSeed,
          );
        }).toList();
      } else if (response.statusCode == 401) {
        throw 'Invalid API key. Please check your OpenAI API configuration.';
      } else if (response.statusCode == 429) {
        throw 'API rate limit exceeded. Please try again in a few moments.';
      } else {
        throw 'Failed to generate questions: ${response.statusCode} - ${response.body}';
      }
    } on http.ClientException catch (e) {
      debugPrint(' Network error during AI generation: $e');
      throw 'Network error. Please check your internet connection.';
    } on FormatException catch (e) {
      // If OpenAI response is not valid JSON, fall back to mock questions
      debugPrint(' Failed to parse OpenAI response: $e');
      debugPrint(' Using fallback questions (limited to 5 per subject)');
      return _generateFallbackQuestions(subject, difficulty, count);
    } catch (e) {
      // If API fails, use fallback questions
      debugPrint(' AI generation failed with error: $e');
      debugPrint(' Using fallback questions (limited to 5 per subject)');
      return _generateFallbackQuestions(subject, difficulty, count);
    }
  }

  // Fallback method when API fails
  List<Question> _generateFallbackQuestions(
    String subject,
    String difficulty,
    int count,
  ) {
    final questions = <Question>[];
    
    for (int i = 0; i < count; i++) {
      questions.add(_createFallbackQuestion(subject, difficulty, i));
    }
    
    return questions;
  }

  Question _createFallbackQuestion(String subject, String difficulty, int index) {
    final mockQuestions = _getFallbackQuestionsForSubject(subject);
    final questionData = mockQuestions[index % mockQuestions.length];
    final questionText = questionData['question']!;
    
    final now = DateTime.now();
    final randomSeed = now.millisecondsSinceEpoch + index;
    
    return Question(
      id: QuestionHashService.generateAttemptId() + '_fallback_$index',
      subject: subject,
      questionText: questionText,
      options: List<String>.from(questionData['options']!),
      correctAnswerIndex: questionData['correctIndex'] as int,
      difficulty: difficulty,
      timeLimitSeconds: 30,
      explanation: questionData['explanation'] ?? '',
      questionHash: QuestionHashService.generateHash(questionText),
      generatedAt: now,
      expiresAt: now.add(Duration(hours: 24)),
      randomSeed: randomSeed,
    );
  }

  List<Map<String, dynamic>> _getFallbackQuestionsForSubject(String subject) {
    if (subject.contains('Mathematics') || subject.contains('Quants')) {
      return _mathQuestions;
    } else if (subject.contains('Logical')) {
      return _reasoningQuestions;
    } else if (subject.contains('Verbal Ability')) {
      return _varcQuestions;
    } else if (subject.contains('Information Technology')) {
      return _itQuestions;
    } else {
      return _mathQuestions;
    }
  }

  // Fallback Mathematics questions
  final List<Map<String, dynamic>> _mathQuestions = [
    {
      'question': 'If x + y = 10 and x - y = 2, what is the value of x?',
      'options': ['4', '6', '8', '10'],
      'correctIndex': 1,
      'explanation': 'Add both equations: 2x = 12, so x = 6',
    },
    {
      'question': 'What is 15% of 200?',
      'options': ['25', '30', '35', '40'],
      'correctIndex': 1,
      'explanation': '15% of 200 = (15/100) × 200 = 30',
    },
    {
      'question': 'A train travels 60 km in 45 minutes. What is its speed in km/h?',
      'options': ['60', '70', '80', '90'],
      'correctIndex': 2,
      'explanation': 'Speed = Distance/Time = 60/(45/60) = 60/(3/4) = 80 km/h',
    },
    {
      'question': 'If the ratio of boys to girls is 3:2 and there are 15 boys, how many girls are there?',
      'options': ['8', '10', '12', '15'],
      'correctIndex': 1,
      'explanation': 'If 3 parts = 15, then 1 part = 5. Girls = 2 parts = 10',
    },
    {
      'question': 'What is the area of a rectangle with length 12 cm and width 5 cm?',
      'options': ['50 cm²', '55 cm²', '60 cm²', '65 cm²'],
      'correctIndex': 2,
      'explanation': 'Area = length × width = 12 × 5 = 60 cm²',
    },
  ];

  // Fallback Logical Reasoning questions
  final List<Map<String, dynamic>> _reasoningQuestions = [
    {
      'question': 'Complete the series: 2, 6, 12, 20, 30, ?',
      'options': ['40', '42', '44', '46'],
      'correctIndex': 1,
      'explanation': 'Pattern: +4, +6, +8, +10, +12. Next is 30+12=42',
    },
    {
      'question': 'If all roses are flowers and some flowers fade quickly, which statement must be true?',
      'options': [
        'All roses fade quickly',
        'Some roses are not flowers',
        'Some roses may fade quickly',
        'No roses fade quickly'
      ],
      'correctIndex': 2,
      'explanation': 'Since all roses are flowers and some flowers fade quickly, it\'s possible some roses fade quickly',
    },
    {
      'question': 'What comes next: A, C, F, J, O, ?',
      'options': ['S', 'T', 'U', 'V'],
      'correctIndex': 2,
      'explanation': 'Pattern: +2, +3, +4, +5, +6. O+6=U',
    },
    {
      'question': 'In a certain code, PLANT is written as QMBOU. How is WATER written?',
      'options': ['XBUFS', 'XBTES', 'WBUFS', 'YBUFS'],
      'correctIndex': 0,
      'explanation': 'Each letter is shifted by +1. W→X, A→B, T→U, E→F, R→S',
    },
    {
      'question': 'If South-East becomes North and North-East becomes West, what does South become?',
      'options': ['North-East', 'North-West', 'South-West', 'East'],
      'correctIndex': 0,
      'explanation': 'Pattern shows 90° anti-clockwise rotation. South becomes North-East',
    },
  ];

  // Fallback VARC questions
  final List<Map<String, dynamic>> _varcQuestions = [
    {
      'question': 'Choose the word most similar in meaning to ABUNDANT:',
      'options': ['Scarce', 'Plentiful', 'Limited', 'Rare'],
      'correctIndex': 1,
      'explanation': 'Abundant means plentiful or available in large quantities',
    },
    {
      'question': 'Choose the correct sentence:',
      'options': [
        'Neither of the students have completed the assignment.',
        'Neither of the students has completed the assignment.',
        'Neither of the student has completed the assignment.',
        'Neither of the student have completed the assignment.'
      ],
      'correctIndex': 1,
      'explanation': '"Neither" is singular and requires "has". "Students" must be plural after "of the"',
    },
    {
      'question': 'Choose the antonym of METICULOUS:',
      'options': ['Careful', 'Careless', 'Detailed', 'Thorough'],
      'correctIndex': 1,
      'explanation': 'Meticulous means very careful and precise, opposite is careless',
    },
    {
      'question': 'Fill in the blank: The manager was known for his _____ approach to problem-solving.',
      'options': ['pragmatic', 'theoretical', 'impractical', 'abstract'],
      'correctIndex': 0,
      'explanation': 'Pragmatic means practical and focused on results',
    },
    {
      'question': 'Identify the error: "The committee have decided to postpone the meeting."',
      'options': [
        'have decided',
        'to postpone',
        'the meeting',
        'No error'
      ],
      'correctIndex': 0,
      'explanation': '"Committee" is a collective noun and should use singular verb "has decided"',
    },
  ];

  // Fallback IT questions
  final List<Map<String, dynamic>> _itQuestions = [
    {
      'question': 'Which data structure uses LIFO (Last In First Out) principle?',
      'options': ['Queue', 'Stack', 'Array', 'Linked List'],
      'correctIndex': 1,
      'explanation': 'Stack follows LIFO - the last element added is the first one removed',
    },
    {
      'question': 'What is the time complexity of binary search in a sorted array?',
      'options': ['O(n)', 'O(n²)', 'O(log n)', 'O(1)'],
      'correctIndex': 2,
      'explanation': 'Binary search divides search space in half each time, giving O(log n) complexity',
    },
    {
      'question': 'In SQL, which command is used to remove all rows from a table?',
      'options': ['DELETE', 'DROP', 'TRUNCATE', 'REMOVE'],
      'correctIndex': 2,
      'explanation': 'TRUNCATE removes all rows from a table efficiently without logging individual deletions',
    },
    {
      'question': 'What does "this" keyword refer to in Java?',
      'options': ['Parent class', 'Current object', 'Static method', 'Constructor'],
      'correctIndex': 1,
      'explanation': '"this" refers to the current instance of the class',
    },
    {
      'question': 'Which scheduling algorithm can cause starvation?',
      'options': ['Round Robin', 'FCFS', 'Priority Scheduling', 'SJF'],
      'correctIndex': 2,
      'explanation': 'Priority Scheduling can cause starvation when high-priority processes keep arriving',
    },
  ];
}
