# 🎯 Aptitude Pro - Placement Preparation App

A Flutter app to help students prepare for placements and competitive exams with quizzes, analytics, authentication, and daily reminder notifications. Works on **Android** and **Web** (Flutter web).

## ✨ Features

### 📚 Subjects Covered
- **Mathematics/Quants** - Arithmetic, Algebra, Data Interpretation
- **Logical Reasoning** - Puzzles, Patterns, Analytical Reasoning  
- **VARC** - Verbal Ability & Reading Comprehension
- **Information Technology** - IT theory + code MCQs

### 🔐 Authentication
- **Email/Password** (Firebase Auth)
- **Google Sign-In** (Firebase Auth)
  - Web uses Firebase popup sign-in
  - Android uses native Google sign-in + Firebase credential
  - Account chooser is forced (so it doesn’t silently reuse a prior session)
- **Persistent session** with auth state listener

### 📝 Quiz System
- Customizable difficulty levels (Easy, Medium, Hard)
- Adjustable question count (5-50 questions)
- 30-second timer per question
- Auto-submit on timeout
- Skip functionality
- Real-time scoring

### 📊 Analytics Dashboard
- Performance tracking with interactive charts
- Subject-wise breakdown
- Trend analysis (Improving/Declining/Stable)
- Weak area identification
- Historical quiz data

### 🏆 Engagement Features
- Daily streak tracking
- Motivational messages based on performance
- Overall accuracy tracking
- Best score highlights

### 🔔 Notifications
- **Daily practice reminder**
- **Time picker** to set reminder time (stored locally)
- Android notification permission supported (Android 13+)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.4.1)
- Dart SDK
- Android Studio / VS Code
- Firebase account

### Installation

1. **Clone or navigate to the project**
   ```bash
   cd aptitude_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Follow the detailed guide in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
   - Create Firebase project
   - Enable Authentication: **Email/Password** + **Google**
   - Create Firestore Database
   - Add `android/app/google-services.json`

4. **Web (Flutter web) setup**
   - In Firebase Console → Authentication → Settings → **Authorized domains**
     - Add your domain (and `localhost` for local testing)

5. **Run the app**
   ```bash
   flutter run
   ```

### Running on Web

```bash
flutter run -d chrome
```

## 📱 Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **State Management**: Provider
- **Charts**: fl_chart
- **Local Storage**: SharedPreferences
- **Notifications**: flutter_local_notifications (+ timezone scheduling)
- **UI**: Material Design 3 + Google Fonts (Inter)

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
├── providers/                   # State management
├── services/                    # Business logic
├── screens/                     # UI screens
├── widgets/                     # Reusable components
└── utils/                       # Utilities & constants
```

Key files:
- `lib/services/auth_service.dart` (email + Google sign-in)
- `lib/services/notification_service.dart` (daily reminder scheduling)
- `lib/screens/profile/notification_settings_screen.dart` (time picker + toggle)

## 🎨 Design Philosophy

- **Professional & Clean**: Placement-ready UI design
- **Color-Coded Subjects**: Easy visual identification
- **Smooth Animations**: Enhanced user experience
- **Responsive**: Works on all screen sizes
- **Dark Mode Ready**: Theme support included

## 🔧 Configuration

### AI API Integration

The app currently uses mock questions. To integrate your AI API:

1. Open `lib/services/ai_service.dart`
2. Update `_apiEndpoint` and `_apiKey`
3. Implement the actual API call
4. Map response to `Question` model

Example:
```dart
final response = await http.post(
  Uri.parse(_apiEndpoint),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  },
  body: jsonEncode({
    'subject': subject,
    'difficulty': difficulty,
    'count': count,
  }),
);
```

## 🏗️ Building for Production

### Android
```bash
flutter build apk --release
```

### Web
```bash
flutter build web
```

## 📝 Environment Setup

### Firebase Configuration Files Required:
- `android/app/google-services.json` (Android)

## 🧪 Testing

The app includes:
- Form validation
- Error handling
- Loading states
- Navigation flows
- Data persistence

## 🔒 Security

- Firebase Authentication
- Firestore security rules
- SHA-1 / SHA-256 fingerprint verification for Google Sign-In (Android)
- Password validation
- Email format validation

## 📚 Documentation

- [Firebase Setup Guide](FIREBASE_SETUP.md)

## 🎯 Sample Questions

The app includes 15 built-in sample questions (5 per subject) for testing:
- Mathematics: Algebra, percentages, ratios, geometry
- Reasoning: Series completion, logic puzzles, coding-decoding
- VARC: Vocabulary, grammar, sentence correction
- IT: All IT topics like OS,CRNS etc.

## 🚀 Future Enhancements

- [ ] Leaderboard system  
- [ ] Offline mode with cached questions
- [ ] Company-specific test modules
- [ ] Resume building tips
- [ ] Social sharing

## 📄 License

This project is created for educational purposes.

## 👨‍💻 Development

Built with ❤️ using Flutter

---

**Ready to ace your placements? Start practicing now! 🎓**
