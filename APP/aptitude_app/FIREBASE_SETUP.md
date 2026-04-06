# Firebase Setup Guide

## Prerequisites
- Flutter installed
- Firebase account (free tier works)
- Android Studio or VS Code

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `aptitude-app` (or your preferred name)
4. Disable Google Analytics (optional for this project)
5. Click "Create project"

## Step 2: Enable Authentication

1. In Firebase Console, click "Authentication" from left menu
2. Click "Get started"
3. Enable the following sign-in methods:
   - **Email/Password**: Toggle to enable
   - **Google**: Toggle to enable, configure support email

## Step 3: Create Firestore Database

1. Click "Firestore Database" from left menu
2. Click "Create database"
3. Select "Start in test mode" (for development)
4. Choose a location close to you
5. Click "Enable"

## Step 4: Add Android App to Firebase

1. In Project Overview, click the Android icon
2. Enter Android package name: `com.aptitude.aptitude_app`
3. Click "Register app"
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`

## Step 5: Configure Android Build Files

### In `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### In `android/app/build.gradle`:
```gradle
// At the bottom of the file, add:
apply plugin: 'com.google.gms.google-services'

// Also update minSdkVersion to 21:
defaultConfig {
    minSdkVersion 21  // Changed from flutter.minSdkVersion
    targetSdkVersion flutter.targetSdkVersion
}
```

## Step 6: Add iOS App to Firebase (Optional)

1. In Firebase Console, click the iOS icon
2. Enter iOS bundle ID: `com.aptitude.aptitudeApp`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`
5. Open Xcode and add the file to Runner folder

## Step 7: Configure Google Sign-In (Android)

### Get SHA-1 Certificate Fingerprint:

**For Debug (Development):**
```bash
cd android
./gradlew signingReport
```

Copy the SHA-1 fingerprint from the output.

**Add to Firebase:**
1. Go to Project Settings in Firebase Console
2. Scroll to "Your apps" section
3. Click your Android app
4. Click "Add fingerprint"
5. Paste SHA-1 fingerprint

## Step 8: Test the Setup

Run the app:
```bash
cd aptitude_app
flutter pub get
flutter run
```

## Firestore Security Rules (Production)

Before deploying to production, update Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Quiz results subcollection
      match /quizResults/{resultId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Troubleshooting

### Common Issues:

1. **"MissingPluginException"**
   - Run: `flutter clean && flutter pub get`
   - Restart the app

2. **"Google Sign-In failed"**
   - Verify SHA-1 fingerprint is added
   - Check package name matches

3. **"Firestore permission denied"**
   - Check Firestore rules (use test mode for development)

## AI API Configuration

The app currently uses mock questions for testing. To integrate a real AI API:

1. Open `lib/services/ai_service.dart`
2. Replace `_apiEndpoint` and `_apiKey` with your actual values
3. Update the `generateQuestions` method to call your API
4. Parse the response according to your API's format

### Example API Integration:
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

## Next Steps

1. Test authentication with email/password
2. Test Google Sign-In
3. Take a quiz and verify Firestore saves data
4. Check analytics and history screens
5. Test on physical device for best experience
