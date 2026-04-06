class UserModel {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime? lastPracticeDate;
  final int currentStreak;
  final int longestStreak;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    this.lastPracticeDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      lastPracticeDate: map['lastPracticeDate'] != null
          ? DateTime.parse(map['lastPracticeDate'] as String)
          : null,
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (map['longestStreak'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serialize to a map suitable for writing to Firestore.
  /// The document ID (`id`) is intentionally omitted — it lives in the path.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastPracticeDate': lastPracticeDate?.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  /// Return a new [UserModel] with selected fields replaced.
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    // Use a sentinel so callers can explicitly pass `null` to clear the date.
    DateTime? lastPracticeDate,
    bool clearLastPracticeDate = false,
    int? currentStreak,
    int? longestStreak,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastPracticeDate: clearLastPracticeDate
          ? null
          : (lastPracticeDate ?? this.lastPracticeDate),
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              email == other.email &&
              name == other.name &&
              createdAt == other.createdAt &&
              lastPracticeDate == other.lastPracticeDate &&
              currentStreak == other.currentStreak &&
              longestStreak == other.longestStreak;

  @override
  int get hashCode => Object.hash(
    id,
    email,
    name,
    createdAt,
    lastPracticeDate,
    currentStreak,
    longestStreak,
  );

  @override
  String toString() => 'UserModel(id: $id, name: $name, '
      'streak: $currentStreak, longest: $longestStreak, '
      'lastPractice: $lastPracticeDate)';
}