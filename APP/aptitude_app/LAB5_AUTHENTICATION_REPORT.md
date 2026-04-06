# LAB 5 – Authentication System: Login, Registration & Logout

**Project:** Aptitude Pro - Placement Preparation App  
**Authentication:** Firebase Authentication (Email/Password)

---

## 1. AIM

To design and implement a functional user authentication system with Login, Registration, and Logout using Firebase Authentication.

---

## 2. Introduction

Authentication ensures only authorized users can access the app. This lab implements:
- Login & Registration screens with validation
- Firebase Authentication integration
- Session management using SharedPreferences
- Logout functionality

---

## 3. Objectives Achieved

✅ Created Login & Registration UI  
✅ Implemented input validation  
✅ Configured Firebase Authentication  
✅ Implemented Login → Home navigation  
✅ Added error handling with user messages  
✅ Implemented Logout with session clearing  
✅ Session persistence across app restarts  

---

## 4. Firebase Setup

### 4.1 Configuration Steps

1. Created Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Added Android app with package: `com.aptitude.aptitude_app`
3. Downloaded `google-services.json` → placed in `android/app/`
4. Enabled **Email/Password** authentication
5. Created **Firestore Database** for user profiles

### 4.2 Dependencies Added

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
```

### 4.3 Firebase Initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalStorageService.init();
  runApp(const MyApp());
}
```

---

## 5. Login Screen

### 5.1 UI Components

- App logo (🎯)
- Email field with validation
- Password field with visibility toggle
- Login button with loading state
- Sign Up link

### 5.2 Input Validation

**Email Validation:**
```dart
static String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}
```

**Password Validation:**
```dart
static String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}
```

### 5.3 Login Logic

```dart
Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;
  
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final success = await authProvider.signIn(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );
  
  if (success && mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } else if (mounted && authProvider.errorMessage != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authProvider.errorMessage!),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### 5.4 Screenshot

![Login Screen](screenshots/login_screen.png)

---

## 6. Registration Screen

### 6.1 UI Components

- Full Name field
- Email field
- Password field
- Confirm Password field
- Sign Up button
- Login link

### 6.2 Validation Rules

| Field | Rule |
|-------|------|
| Name | Required, min 2 characters |
| Email | Required, valid format |
| Password | Required, min 6 characters |
| Confirm Password | Must match password |

### 6.3 Registration Logic

```dart
Future<void> _handleSignUp() async {
  if (!_formKey.currentState!.validate()) return;
  
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final success = await authProvider.signUp(
    email: _emailController.text.trim(),
    password: _passwordController.text,
    name: _nameController.text.trim(),
  );
  
  if (success && mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}
```

### 6.4 Screenshot

![Sign Up Screen](screenshots/signup_screen.png)

---

## 7. Authentication Service

### 7.1 Sign Up Function

```dart
Future<UserCredential?> signUpWithEmail({
  required String email,
  required String password,
  required String name,
}) async {
  try {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    await credential.user?.updateDisplayName(name);
    
    // Save session
    await LocalStorageService.setLoginState(true);
    await LocalStorageService.setUserId(credential.user!.uid);
    await LocalStorageService.setUserEmail(email);
    
    return credential;
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  }
}
```

### 7.2 Sign In Function

```dart
Future<UserCredential?> signInWithEmail({
  required String email,
  required String password,
}) async {
  try {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Save session
    await LocalStorageService.setLoginState(true);
    await LocalStorageService.setUserId(credential.user!.uid);
    await LocalStorageService.setUserEmail(email);
    
    return credential;
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  }
}
```

### 7.3 Error Handling

```dart
String _handleAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'weak-password':
      return 'The password provided is too weak.';
    case 'email-already-in-use':
      return 'An account already exists for this email.';
    case 'user-not-found':
      return 'No user found with this email.';
    case 'wrong-password':
      return 'Wrong password provided.';
    case 'invalid-email':
      return 'The email address is not valid.';
    default:
      return 'Authentication failed. Please try again.';
  }
}
```

---

## 8. Session Management

### 8.1 LocalStorageService

```dart
class LocalStorageService {
  static SharedPreferences? _preferences;
  
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }
  
  // Login state
  static Future<bool> setLoginState(bool isLoggedIn) async {
    return await _preferences!.setBool('isLoggedIn', isLoggedIn);
  }
  
  static bool get isLoggedIn {
    return _preferences!.getBool('isLoggedIn') ?? false;
  }
  
  // User ID
  static Future<bool> setUserId(String userId) async {
    return await _preferences!.setString('userId', userId);
  }
  
  static String get userId {
    return _preferences!.getString('userId') ?? '';
  }
  
  // Clear all (logout)
  static Future<void> clearAll() async {
    await _preferences!.clear();
  }
}
```

---

## 9. Logout Implementation

### 9.1 Logout Function

```dart
Future<void> signOut() async {
  try {
    await _auth.signOut();
    await LocalStorageService.clearAll();
  } catch (e) {
    throw 'Failed to sign out. Please try again.';
  }
}
```

### 9.2 Logout Button (Profile Screen)

```dart
ElevatedButton.icon(
  onPressed: () async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await authProvider.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  },
  icon: const Icon(Icons.logout),
  label: const Text('Logout'),
)
```

### 9.3 Screenshot

![Logout](screenshots/logout_screen.png)

---

## 10. State Management (Provider)

### 10.1 AuthProvider

```dart
class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isAuthenticated => _currentUser != null;
  
  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      
      // Save user profile to Firestore
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );
      await _firestoreService.saveUserProfile(userModel);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      return credential != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
```

---

## 11. Navigation Flow

```
App Start
    ↓
Check Session (isLoggedIn?)
    ↓
   Yes → Home Screen
    ↓
   No → Login Screen
    ↓
Login/Register → Firebase Auth
    ↓
Success → Home Screen
    ↓
Logout → Clear Session → Login Screen
```

---

## 12. Testing Results

| Test Case | Input | Result | Status |
|-----------|-------|--------|--------|
| Valid Registration | Valid email, password ≥6 | Account created | ✅ |
| Duplicate Email | Existing email | Error shown | ✅ |
| Weak Password | Password <6 chars | Error shown | ✅ |
| Invalid Email | "test@" | Error shown | ✅ |
| Password Mismatch | Different passwords | Error shown | ✅ |
| Valid Login | Correct credentials | Login success | ✅ |
| Wrong Password | Incorrect password | Error shown | ✅ |
| Logout | Click logout | Session cleared | ✅ |
| Session Persistence | Reopen app | Stays logged in | ✅ |

---

## 13. Screenshots

### Login Screen
![Login Screen](screenshots/login_screen.png)

### Registration Screen
![Sign Up Screen](screenshots/signup_screen.png)

### Home Screen After Login
![Home Screen](screenshots/home_screen.png)

### Profile Screen with Logout
![Profile Screen](screenshots/profile_screen.png)

---

## 14. Folder Structure

```
lib/
├── models/
│   └── user_model.dart
├── providers/
│   └── auth_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   └── home/
│       └── home_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── local_storage_service.dart
├── utils/
│   └── validators.dart
└── main.dart
```

---

## 15. Tools Used

- **IDE:** Visual Studio Code
- **Framework:** Flutter
- **Authentication:** Firebase Authentication
- **Database:** Cloud Firestore
- **State Management:** Provider
- **Local Storage:** SharedPreferences

---

## 16. Workflow Summary

**Registration:**
1. User enters details → Validates → Creates Firebase account → Saves to Firestore → Navigates to Home

**Login:**
1. User enters credentials → Validates → Authenticates with Firebase → Saves session → Navigates to Home

**Logout:**
1. User clicks logout → Confirms → Signs out from Firebase → Clears session → Navigates to Login

---

## 17. Conclusion

Successfully implemented a complete authentication system with:
- ✅ Login & Registration screens
- ✅ Firebase Authentication integration
- ✅ Input validation
- ✅ Session management
- ✅ Logout functionality
- ✅ Error handling
- ✅ User profile storage in Firestore

The authentication module is production-ready and serves as the foundation for all user-specific features.

---

**Student Name:** _____________________  
**Roll Number:** _____________________  
**Date:** _____________________  
**Instructor Signature:** _____________________
