import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  User? _currentUser;
  UserModel? _userModel;
  bool _isLoading = true; // Start true until first auth state is known
  String? _errorMessage;
  
  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  
  AuthProvider() {
    _initAuth();
  }
  
  void _initAuth() {
    try {
      _currentUser = _authService.currentUser;
      _authService.authStateChanges.listen(
        (User? user) {
          _currentUser = user;
          if (user != null) {
            _loadUserProfile(user.uid);
          } else {
            _userModel = null;
          }
          _isLoading = false;
          notifyListeners();
        },
        onError: (Object e, StackTrace st) {
          debugPrint('Auth stream error: $e');
          _isLoading = false;
          _errorMessage = e.toString();
          notifyListeners();
        },
        cancelOnError: false,
      );
      if (_currentUser != null) {
        _loadUserProfile(_currentUser!.uid);
      }
      notifyListeners();
      // If stream doesn't emit (e.g. web without auth), stop loading after 3s
      Future.delayed(const Duration(seconds: 3), () {
        if (_isLoading) {
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e, st) {
      debugPrint('Auth init error: $e $st');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> _loadUserProfile(String userId) async {
    try {
      _userModel = await _firestoreService.getUserProfile(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }
  
  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      
      if (credential != null && credential.user != null) {
        // Create user profile in Firestore
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
        );
        
        await _firestoreService.saveUserProfile(userModel);
        _userModel = userModel;
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
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
  
  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final credential = await _authService.signInWithGoogle();
      
      if (credential != null && credential.user != null) {
        // Check if user profile exists, if not create it
        final existingProfile = await _firestoreService.getUserProfile(
          credential.user!.uid,
        );
        
        if (existingProfile == null) {
          final userModel = UserModel(
            id: credential.user!.uid,
            email: credential.user!.email ?? '',
            name: credential.user!.displayName ?? 'User',
            createdAt: DateTime.now(),
          );
          
          await _firestoreService.saveUserProfile(userModel);
          _userModel = userModel;
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.signOut();
      _currentUser = null;
      _userModel = null;
      _errorMessage = null;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
