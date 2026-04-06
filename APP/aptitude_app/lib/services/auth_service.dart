import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'local_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign up with email and password
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
      
      // Update display name
      await credential.user?.updateDisplayName(name);
      
      // Save login state
      await LocalStorageService.setLoginState(true);
      await LocalStorageService.setUserId(credential.user!.uid);
      await LocalStorageService.setUserEmail(email);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }
  
  // Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save login state
      await LocalStorageService.setLoginState(true);
      await LocalStorageService.setUserId(credential.user!.uid);
      await LocalStorageService.setUserEmail(email);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }
  
  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web must use Firebase popup/redirect instead of google_sign_in plugin flow.
        final provider = GoogleAuthProvider()..setCustomParameters({
          'prompt': 'select_account',
        });
        userCredential = await _auth.signInWithPopup(provider);
      } else {
        // Trigger native Google Sign-In flow for Android/iOS.
        // Force account chooser each time to avoid silently reusing a previous session.
        await _googleSignIn.signOut();
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // User cancelled

        // Obtain auth details
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a Firebase credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase
        userCredential = await _auth.signInWithCredential(credential);
      }

      // Save login state
      await LocalStorageService.setLoginState(true);
      await LocalStorageService.setUserId(userCredential.user!.uid);
      await LocalStorageService.setUserEmail(userCredential.user!.email ?? '');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google Sign-In failed. Please try again.';
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await LocalStorageService.clearAll();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }
  
  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'popup-closed-by-user':
        return 'Google sign-in was cancelled before completion.';
      case 'popup-blocked':
        return 'Pop-up was blocked by the browser. Please allow pop-ups and try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using another sign-in method.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled in Firebase Authentication.';
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
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
