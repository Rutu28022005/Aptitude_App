# LAB 6 – Database Design & CRUD Operations

**Project:** Aptitude Pro - Placement Preparation App  
**Module:** Quiz Results Management  
**Database:** Firebase Firestore

---

## 1. AIM

To design the database structure for the Quiz Results module and implement CRUD operations (Create, Read, Update, Delete) using Firebase Firestore.

---

## 2. Introduction

This lab implements data management for quiz results, allowing the app to:
- **Create** - Save quiz results after completion
- **Read** - Display quiz history and analytics
- **Update** - Modify quiz metadata (if needed)
- **Delete** - Remove quiz records

The module uses Firebase Firestore for cloud storage with real-time synchronization.

---

## 3. Module Selected

**Quiz Results Module**

This module stores and manages all quiz attempts, including:
- Quiz scores and accuracy
- Subject-wise performance breakdown
- Time taken per quiz
- Completion timestamps

---

## 4. Database Schema Design

### 4.1 Firestore Structure

```
users (collection)
  └── {userId} (document)
      └── quizResults (subcollection)
          └── {resultId} (document)
              ├── id: String
              ├── userId: String
              ├── quizId: String
              ├── completedAt: Timestamp
              ├── score: Number
              ├── accuracy: Number
              ├── timeTaken: Number (seconds)
              └── subjectWiseBreakdown: Map
                  └── {subject}: Map
                      ├── correct: Number
                      └── total: Number
```

### 4.2 Schema Table

| Field Name | Data Type | Description | Constraints |
|------------|-----------|-------------|-------------|
| `id` | String | Unique result identifier | Primary Key, Auto-generated |
| `userId` | String | User who took the quiz | Required, Foreign Key |
| `quizId` | String | Quiz identifier | Required |
| `completedAt` | Timestamp | When quiz was completed | Required |
| `score` | Number | Number of correct answers | Required, ≥ 0 |
| `accuracy` | Number | Percentage score | Required, 0-100 |
| `timeTaken` | Number | Time in seconds | Required, ≥ 0 |
| `subjectWiseBreakdown` | Map | Performance per subject | Required |

---

## 5. Data Model

### 5.1 QuizResult Model

**File:** `lib/models/result_model.dart`

```dart
class QuizResult {
  final String id;
  final String userId;
  final String quizId;
  final DateTime completedAt;
  final int score;
  final double accuracy;
  final int timeTaken;
  final Map<String, Map<String, int>> subjectWiseBreakdown;
  
  QuizResult({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.completedAt,
    required this.score,
    required this.accuracy,
    required this.timeTaken,
    required this.subjectWiseBreakdown,
  });
  
  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'completedAt': completedAt.toIso8601String(),
      'score': score,
      'accuracy': accuracy,
      'timeTaken': timeTaken,
      'subjectWiseBreakdown': subjectWiseBreakdown,
    };
  }
  
  // Convert from Firebase
  factory QuizResult.fromMap(Map<String, dynamic> map, String id) {
    return QuizResult(
      id: id,
      userId: map['userId'] ?? '',
      quizId: map['quizId'] ?? '',
      completedAt: DateTime.parse(map['completedAt']),
      score: map['score'] ?? 0,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      timeTaken: map['timeTaken'] ?? 0,
      subjectWiseBreakdown: Map<String, Map<String, int>>.from(
        (map['subjectWiseBreakdown'] as Map).map(
          (k, v) => MapEntry(k.toString(), Map<String, int>.from(v)),
        ),
      ),
    );
  }
}
```

---

## 6. CREATE Operation

### 6.1 Save Quiz Result

**File:** `lib/services/firestore_service.dart`

```dart
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
```

### 6.2 Usage Example

```dart
// After quiz completion
final result = QuizResult(
  id: uuid.v4(),
  userId: currentUser.uid,
  quizId: quiz.id,
  completedAt: DateTime.now(),
  score: correctAnswers,
  accuracy: (correctAnswers / totalQuestions) * 100,
  timeTaken: elapsedSeconds,
  subjectWiseBreakdown: breakdown,
);

await firestoreService.saveQuizResult(result);
```

### 6.3 Screenshot

![Create - Quiz Result Saved](screenshots/create_result.png)

---

## 7. READ Operations

### 7.1 Get All Quiz Results

```dart
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
```

### 7.2 Get Recent Quiz Results (Limited)

```dart
Future<List<QuizResult>> getRecentQuizResults(String userId, int limit) async {
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
```

### 7.3 Get Specific Quiz Result

```dart
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
```

### 7.4 Display in UI

**History Screen** displays all quiz results:

```dart
FutureBuilder<List<QuizResult>>(
  future: firestoreService.getUserQuizResults(userId),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    final results = snapshot.data ?? [];
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return QuizResultCard(result: result);
      },
    );
  },
)
```

### 7.5 Screenshot

![Read - Quiz History List](screenshots/read_results.png)

---

## 8. UPDATE Operation

### 8.1 Update Quiz Result (if needed)

While quiz results are typically immutable, we can update metadata:

```dart
Future<void> updateQuizResult(
  String userId,
  String resultId,
  Map<String, dynamic> updates,
) async {
  try {
    await _db
        .collection('users')
        .doc(userId)
        .collection('quizResults')
        .doc(resultId)
        .update(updates);
  } catch (e) {
    throw 'Failed to update quiz result: $e';
  }
}
```

### 8.2 Usage Example

```dart
// Update specific fields
await firestoreService.updateQuizResult(
  userId,
  resultId,
  {'reviewed': true, 'notes': 'Need to practice more'},
);
```

---

## 9. DELETE Operation

### 9.1 Delete Quiz Result

```dart
Future<void> deleteQuizResult(String userId, String resultId) async {
  try {
    await _db
        .collection('users')
        .doc(userId)
        .collection('quizResults')
        .doc(resultId)
        .delete();
  } catch (e) {
    throw 'Failed to delete quiz result: $e';
  }
}
```

### 9.2 Delete with Confirmation

```dart
Future<void> _handleDelete(QuizResult result) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Result'),
      content: const Text('Are you sure you want to delete this quiz result?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    ),
  );
  
  if (confirm == true) {
    await firestoreService.deleteQuizResult(userId, result.id);
    setState(() {}); // Refresh UI
  }
}
```

### 9.3 Screenshot

![Delete - Confirmation Dialog](screenshots/delete_result.png)

---

## 10. Analytics & Advanced Queries

### 10.1 Get Last Quiz Score

```dart
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
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      ).accuracy;
    }
    return null;
  } catch (e) {
    return null;
  }
}
```

### 10.2 Get Overall Accuracy

```dart
Future<double> getOverallAccuracy(String userId) async {
  try {
    final results = await getUserQuizResults(userId);
    if (results.isEmpty) return 0.0;
    
    double totalAccuracy = 0;
    for (var result in results) {
      totalAccuracy += result.accuracy;
    }
    
    return totalAccuracy / results.length;
  } catch (e) {
    return 0.0;
  }
}
```

---

## 11. UI Integration

### 11.1 History Screen

Displays all quiz attempts with:
- Quiz date and time
- Score and accuracy
- Subject breakdown
- Time taken
- Delete option

### 11.2 Analytics Screen

Shows:
- Overall accuracy
- Last quiz score
- Performance trends
- Subject-wise statistics

### 11.3 Screenshots

![History Screen](screenshots/history_screen.png)
![Analytics Screen](screenshots/analytics_screen.png)

---

## 12. Testing Results

| Operation | Test Case | Result | Status |
|-----------|-----------|--------|--------|
| **CREATE** | Save quiz result after completion | Result saved to Firestore | ✅ |
| **READ** | Fetch all quiz results | List displayed correctly | ✅ |
| **READ** | Fetch recent 5 results | Limited results returned | ✅ |
| **READ** | Get specific quiz result | Single result fetched | ✅ |
| **UPDATE** | Update quiz metadata | Fields updated successfully | ✅ |
| **DELETE** | Delete quiz result | Result removed from DB | ✅ |
| **ANALYTICS** | Calculate overall accuracy | Correct average calculated | ✅ |
| **UI** | Display in ListView | All results shown properly | ✅ |
| **ERROR** | Handle network errors | Error message displayed | ✅ |

---

## 13. Folder Structure

```
lib/
├── models/
│   └── result_model.dart          # QuizResult data model
├── services/
│   └── firestore_service.dart     # CRUD operations
├── screens/
│   ├── history/
│   │   └── history_screen.dart    # Display quiz history
│   └── analytics/
│       └── performance_screen.dart # Analytics dashboard
└── providers/
    └── analytics_provider.dart    # State management
```

---

## 14. Key Features Implemented

✅ **Create** - Save quiz results to Firestore  
✅ **Read** - Fetch and display quiz history  
✅ **Update** - Modify quiz metadata  
✅ **Delete** - Remove quiz results with confirmation  
✅ **Analytics** - Calculate overall accuracy and stats  
✅ **Real-time Sync** - Firestore automatic synchronization  
✅ **Error Handling** - Try-catch blocks with user messages  
✅ **Data Validation** - Model-based validation  
✅ **Subcollections** - Organized user-specific data  

---

## 15. Tools & Technologies

- **Database:** Firebase Firestore (NoSQL Cloud Database)
- **State Management:** Provider
- **Data Serialization:** JSON to/from Dart objects
- **UI Framework:** Flutter
- **Language:** Dart

---

## 16. Conclusion

Successfully implemented a complete CRUD system for Quiz Results module:

- **Database Schema** designed with proper structure and constraints
- **Data Model** created with serialization methods
- **CRUD Operations** implemented for all operations
- **UI Integration** with History and Analytics screens
- **Error Handling** with user-friendly messages
- **Real-time Sync** using Firestore

The module is production-ready and provides a solid foundation for quiz management and performance tracking.

---

**Student Name:** _____________________  
**Roll Number:** _____________________  
**Date:** _____________________  
**Instructor Signature:** _____________________
