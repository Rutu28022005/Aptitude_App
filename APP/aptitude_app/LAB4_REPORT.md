# LAB 4 – Designing UI Screens Using Layouts, Widgets & Components

**Project:** Aptitude Pro - Placement Preparation App

---

## 1. AIM

To design and build user interface screens using basic and advanced UI widgets and components, implement layout structures, and create visually clean, responsive, and user-friendly mobile application screens.

---

## 2. Introduction

User Interface (UI) is the heart of any mobile application. It determines how users interact with the system and influences usability and overall user satisfaction. A well-designed UI makes applications intuitive, efficient, and visually appealing.

In this lab, UI screens are designed using Flutter by applying layout widgets such as `Row`, `Column`, `Container`, and `Stack` along with commonly used UI widgets like `TextField`, `Button`, `Image`, `Icon`, and `Card`. Proper styling, responsive design principles, and reusable components are implemented to ensure a clean and maintainable UI.

This practical prepares students for future UI enhancements and later integration of CRUD operations, navigation, and state management.

---

## 3. Practical Objectives

The objectives of this lab are:
- To implement UI layouts using common Flutter widgets and components
- To apply proper alignment, spacing, and styling properties
- To design Login, Sign Up, Home Dashboard, Quiz, and Result screens
- To utilize form fields, buttons, cards, and gradient designs
- To understand responsive UI design practices
- To structure UI code using reusable components

---

## 4. Screens Designed

For this lab, the following UI screens are designed:
1. **Login Screen**
2. **Sign Up Screen**
3. **Home Dashboard Screen**
4. **Quiz Configuration Screen**
5. **Quiz Question Screen**
6. **Result Screen**

Additional supporting screens such as History, Profile, and Analytics are also implemented to demonstrate UI consistency.

---

## 5. Login Screen Design

### 5.1 Components Used
- App logo (Emoji icon 🎯)
- Email input field with validation
- Password input field with visibility toggle
- Login button with loading state
- Google Sign-In button
- "Sign Up" navigation link

### 5.2 Widgets Used
- `Scaffold`
- `SafeArea`
- `SingleChildScrollView`
- `Form` and `TextFormField`
- `Column`
- `Padding`
- `SizedBox`
- `Text`
- `Icon`
- `ElevatedButton`
- `CustomButton` (reusable component)
- `Consumer` (Provider for state management)

### 5.3 Layout Design Description

The Login Screen is designed using a `Column` widget wrapped inside a `SingleChildScrollView` to avoid overflow on smaller screens. `SafeArea` ensures the content doesn't overlap with system UI elements. 

The screen features:
- **Clean visual hierarchy** with proper spacing using `SizedBox`
- **Form validation** using `GlobalKey<FormState>` and custom validators
- **Password visibility toggle** using `IconButton` with state management
- **Loading states** handled via `Consumer<AuthProvider>`
- **Google Sign-In integration** with custom button styling
- **Consistent theme colors** applied throughout

### 5.4 Screenshot

![Login Screen](screenshots/login_screen.png)

*Figure 1: Login Screen with email/password fields and Google Sign-In option*

---

### 5.5 Code Snippet – Login Screen

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
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
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo/Title
                Text('🎯', textAlign: TextAlign.center, 
                     style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                Text('Aptitude Pro', textAlign: TextAlign.center,
                     style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                           fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Master your placement preparation',
                     textAlign: TextAlign.center,
                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                           color: Colors.grey[600])),
                
                const SizedBox(height: 48),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'your.email@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.validateEmail,
                ),
                
                const SizedBox(height: 16),
                
                // Password field with visibility toggle
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: Validators.validatePassword,
                ),
                
                const SizedBox(height: 24),
                
                // Login button with loading state
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      text: 'Login',
                      onPressed: _handleLogin,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: Colors.grey[600])),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Google Sign In
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      text: 'Continue with Google',
                      onPressed: _handleGoogleSignIn,
                      isLoading: authProvider.isLoading,
                      isOutlined: true,
                      icon: Icons.g_mobiledata,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 6. Sign Up Screen Design

### 6.1 Components Used
- Full name input field
- Email input field with validation
- Password input field with visibility toggle
- Confirm password field with matching validation
- Sign Up button with loading state
- "Login" navigation link

### 6.2 Widgets Used
- `Scaffold`
- `AppBar`
- `SafeArea`
- `SingleChildScrollView`
- `Form` and `TextFormField`
- `Column`
- `CustomButton` (reusable component)
- State management with Provider

### 6.3 Layout Design Description

The Sign Up Screen follows the same clean design pattern as the Login Screen. It includes:
- **Multi-field form validation** for name, email, password, and password confirmation
- **Password strength validation** ensuring minimum 6 characters
- **Real-time validation feedback** using Flutter's form validators
- **Consistent spacing** and visual hierarchy
- **Responsive layout** that adapts to different screen sizes

### 6.4 Screenshot

![Sign Up Screen](screenshots/signup_screen.png)

*Figure 2: Sign Up Screen with name, email, password, and confirm password fields*

---

## 7. Home Dashboard Screen Design

### 7.1 Components Used
- Welcome section with gradient background
- Statistics cards (Last Score, Accuracy, Streak)
- Quick action cards for navigation
- App bar with profile button

### 7.2 Widgets Used
- `Scaffold`
- `AppBar`
- `RefreshIndicator`
- `SingleChildScrollView`
- `Column`
- `Row`
- `Container` with gradient decoration
- `Card`
- `Icon`
- `Text`
- `GestureDetector`

### 7.3 Layout Design Description

The Home Dashboard serves as the main navigation hub of the application. It displays:
- **Gradient welcome card** with personalized greeting
- **Three stat cards** showing Last Score, Accuracy, and Streak with color-coded indicators
- **Four action cards** in a grid layout for:
  - Start Quiz 📝
  - Progress 📊
  - History 📚
  - Profile 👤
- **Pull-to-refresh** functionality to reload stats
- **Modern card-based design** with shadows and rounded corners

### 7.4 Screenshot

![Home Dashboard](screenshots/home_screen.png)

*Figure 3: Home Dashboard with welcome card, stats, and quick action buttons*

---

### 7.5 Code Snippet – Home Dashboard

```dart
Widget _buildWelcomeSection(String userName) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName! 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ready to ace your placement prep?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatCard(String label, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionCard(String title, String emoji, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## 8. Quiz Question Screen Design

### 8.1 Components Used
- Progress indicator
- Question counter
- Timer widget
- Subject chip/badge
- Question card
- Multiple choice option cards
- Skip and Submit buttons

### 8.2 Widgets Used
- `Scaffold`
- `AppBar`
- `LinearProgressIndicator`
- `Column`
- `SingleChildScrollView`
- `Card`
- `Chip`
- `Text`
- `AnimatedContainer`
- `GestureDetector`
- `QuizTimer` (custom widget)
- Consumer (Provider pattern)

### 8.3 Layout Design Description

The Quiz Question Screen displays questions with:
- **Linear progress bar** showing quiz completion
- **Custom timer widget** with countdown animation
- **Subject badge** with color coding
- **Question card** with gray background for readability
- **Selectable option cards** with:
  - Border color change on selection
  - Check icon indicator
  - Smooth animations using `AnimatedContainer`
- **Action buttons** (Skip and Submit/Next)
- **Back button confirmation dialog** to prevent accidental exits

### 8.4 Screenshot

![Quiz Question Screen](screenshots/quiz_screen.png)

*Figure 4: Quiz Question Screen with timer, progress bar, and selectable options*

---

### 8.5 Code Snippet – Quiz Screen Option Card

```dart
Widget _buildOptionCard(int index, String option, bool isSelected) {
  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedOption = index;
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? AppConstants.primaryColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppConstants.primaryColor
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppConstants.primaryColor
                  : Colors.grey[300],
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## 9. Result Screen Design

### 9.1 Components Used
- Animated score card with gradient
- Trophy/medal emoji based on performance
- Celebration message
- Subject-wise performance breakdown with progress bars
- Statistics cards (Time taken, Accuracy)
- Motivational message
- Action buttons (Home, Retake Quiz)
- Confetti animation for high scores

### 9.2 Widgets Used
- `Scaffold`
- `Stack` (for confetti overlay)
- `SingleChildScrollView`
- `AnimatedBuilder`
- `TweenAnimationBuilder`
- `FadeTransition`
- `SlideTransition`
- `Container` with gradient
- `Card`
- `LinearProgressIndicator`
- `AnimatedButton` (custom widget)
- `ConfettiAnimation` (custom widget)

### 9.3 Layout Design Description

The Result Screen showcases:
- **Smooth entrance animations** for all elements
- **Gradient score card** with emoji indicators (🏆, 🥇, ⭐, 💪)
- **Animated score counter** that counts up to final percentage
- **Color-coded performance** (Green for excellent, Purple for good, etc.)
- **Subject breakdown** with animated progress bars
- **Confetti particles** for scores above 70%
- **Motivational messages** based on performance
- **Clean action buttons** for navigation

### 9.4 Screenshot

![Result Screen](screenshots/result_screen.png)

*Figure 5: Result Screen with animated score card, subject breakdown, and confetti animation*

---

### 9.5 Code Snippet – Result Screen Score Card

```dart
Widget _buildAnimatedScoreCard(BuildContext context, QuizResult result) {
  final color = result.accuracy >= AppConstants.excellentThreshold
      ? AppConstants.successColor
      : result.accuracy >= AppConstants.goodThreshold
          ? AppConstants.accentColor
          : result.accuracy >= AppConstants.averageThreshold
              ? AppConstants.warningColor
              : AppConstants.errorColor;
  
  return Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color, color.withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          result.accuracy >= AppConstants.excellentThreshold ? '🏆'
              : result.accuracy >= AppConstants.goodThreshold ? '🥇'
              : result.accuracy >= AppConstants.averageThreshold ? '⭐' : '💪',
          style: const TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 16),
        const Text('Your Score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2)),
        const SizedBox(height: 12),
        
        // Animated score counter
        TweenAnimationBuilder<double>(
          duration: AppConstants.extraLongAnimationDuration,
          tween: Tween(begin: 0, end: result.accuracy),
          builder: (context, value, child) {
            return Text(
              '${value.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.bold,
                height: 1.0,
                letterSpacing: -2,
              ),
            );
          },
        ),
      ],
    ),
  );
}
```

---

## 10. Reusable UI Components

To reduce code repetition and improve maintainability, the following reusable UI components are created:

### 10.1 CustomButton Widget

**Purpose:** Provides consistent button styling with loading states and optional icons

**Features:**
- Loading indicator support
- Outlined and filled variants
- Optional icon display
- Custom color support

**File:** `lib/widgets/custom_button.dart`

```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  
  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(),
      );
    }
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(),
    );
  }
  
  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    
    return Text(text);
  }
}
```

### 10.2 GradientCard Widget

**Purpose:** Creates beautiful gradient cards with optional glassmorphism effect

**Features:**
- Custom gradient support
- Rounded corners
- Shadow effects
- Glassmorphism with backdrop blur
- Tap gesture support

**File:** `lib/widgets/gradient_card.dart`

### 10.3 AnimatedButton Widget

**Purpose:** Button with gradient and scale animation on press

**File:** `lib/widgets/animated_button.dart`

### 10.4 QuizTimer Widget

**Purpose:** Circular timer with countdown display

**File:** `lib/widgets/quiz_timer.dart`

### 10.5 ConfettiAnimation Widget

**Purpose:** Particle animation for celebrating good scores

**File:** `lib/widgets/confetti_animation.dart`

### 10.6 Other Reusable Widgets
- `SubjectCard` - Card displaying subject info
- `LoadingOverlay` - Full-screen loading indicator
- `PerformanceChart` - Charts for analytics

---

## 11. Responsive Design

Responsive UI design is achieved using:

### 11.1 Layout Techniques
- `SafeArea` to avoid system UI overlap (status bar, notches)
- `SingleChildScrollView` for scrollable content on smaller screens
- `Flexible` and `Expanded` widgets for adaptive sizing
- `MediaQuery` for screen size detection
- Proper spacing with `SizedBox` and `Padding`

### 11.2 Design Patterns
- **Column for vertical layouts** with proper spacing
- **Row for horizontal stat cards** with equal distribution
- **Stack for overlays** (confetti, loading screens)
- **Card widgets** with consistent elevation and shadows
- **Gradient backgrounds** for modern aesthetics

### 11.3 Best Practices
- Minimum touch target size of 44x44 pixels
- Readable text sizes (minimum 14sp for body text)
- High contrast ratios for accessibility
- Proper error handling and user feedback
- Loading states for async operations

---

## 12. Folder Structure

The application follows a clean and modular folder structure:

```
lib/
├── config/
│   └── api_config.dart
├── models/
│   ├── question_model.dart
│   ├── quiz_model.dart
│   ├── result_model.dart
│   └── user_model.dart
├── providers/
│   ├── analytics_provider.dart
│   ├── auth_provider.dart
│   └── quiz_provider.dart
├── screens/
│   ├── analytics/
│   │   └── performance_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── history/
│   │   └── history_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── quiz/
│       ├── quiz_config_screen.dart
│       ├── quiz_screen.dart
│       └── result_screen.dart
├── services/
│   ├── ai_service.dart
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── local_storage_service.dart
│   ├── question_hash_service.dart
│   └── streak_service.dart
├── utils/
│   ├── constants.dart
│   ├── theme.dart
│   └── validators.dart
├── widgets/
│   ├── animated_button.dart
│   ├── confetti_animation.dart
│   ├── custom_button.dart
│   ├── gradient_card.dart
│   ├── loading_overlay.dart
│   ├── performance_chart.dart
│   ├── quiz_timer.dart
│   └── subject_card.dart
├── firebase_options.dart
└── main.dart
```

### 12.1 Folder Organization Principles

- **screens/** - All UI screens organized by feature
- **widgets/** - Reusable UI components
- **models/** - Data models for type safety
- **providers/** - State management using Provider pattern
- **services/** - Business logic and API calls
- **utils/** - Constants, themes, and helper functions
- **config/** - Configuration files

---

## 13. Modern UI Features Implemented

### 13.1 Gradients
- Linear gradients for cards and backgrounds
- Color schemes: Purple-Indigo (Primary), Cyan (Info), Green (Success), Amber (Warning)

### 13.2 Animations
- Fade transitions for screen elements
- Slide transitions for cards
- Scale animations for buttons
- Progress bar animations
- Confetti particle animations
- Animated score counter

### 13.3 Visual Enhancements
- Card shadows with blur radius
- Rounded corners (12-24px radius)
- Icon decorations with colors
- Emoji usage for visual appeal
- Color-coded performance indicators

---

## 14. Widgets Summary Table

| Widget Type | Usage Count | Purpose |
|------------|-------------|---------|
| `Scaffold` | 6 screens | Base screen structure |
| `Column` | Multiple | Vertical layouts |
| `Row` | Multiple | Horizontal layouts |
| `Container` | Multiple | Styling and decoration |
| `Card` | 15+ | Elevated content blocks |
| `TextFormField` | 7 | User input with validation |
| `ElevatedButton` | Multiple | Primary actions |
| `Icon` | 20+ | Visual indicators |
| `Text` | 50+ | Content display |
| `SingleChildScrollView` | 6 | Scrollable content |
| `SafeArea` | 6 | System UI padding |
| `Provider/Consumer` | 8+ | State management |

---

## 15. Expected Outcome

After completing this lab:
✅ **Six working UI screens** are implemented (Login, Signup, Home, Quiz Config, Quiz, Results)  
✅ **Clean and visually appealing layouts** with modern gradients and animations  
✅ **Proper use of Flutter widgets** including forms, cards, buttons, and containers  
✅ **Responsive UI behavior** achieved across different screen sizes  
✅ **Eight reusable components** successfully implemented for code maintainability  
✅ **Form validation** with custom validators for email, password, and name  
✅ **State management** using Provider pattern for loading states and data  
✅ **Navigation flow** between all screens with proper routing  

---

## 16. Conclusion

This lab provided comprehensive hands-on experience in designing mobile UI screens using Flutter layouts and widgets. By implementing Login, Sign Up, Home Dashboard, Quiz, and Result screens along with eight reusable components, a clean, responsive, and user-friendly interface was achieved. 

**Key achievements:**
- Implemented modern UI patterns with gradients and animations
- Created reusable widget components for maintainability
- Applied responsive design principles for various screen sizes
- Integrated form validation and error handling
- Implemented state management using Provider pattern
- Designed intuitive user flows with proper navigation

The application UI is now ready for future integration with backend services (Firebase), AI-powered question generation (OpenAI), and advanced features like progress tracking and analytics.

**Technologies Used:**
- Flutter SDK
- Provider (State Management)
- Material Design Components
- Firebase Authentication
- Custom Animations and Transitions

---

**Student Name:** _____________________  
**Roll Number:** _____________________  
**Date:** _____________________  
**Instructor Signature:** _____________________
