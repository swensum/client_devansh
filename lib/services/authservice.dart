import 'package:devansh/models/authmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Singleton wrapper around FirebaseAuth.
class AuthService {
  AuthService._internal() {
    debugPrint('🔷 AuthService: Initializing...');
    
    // Set initial value
    final currentFirebaseUser = _auth.currentUser;
    debugPrint('🔷 AuthService: Current Firebase user: ${currentFirebaseUser?.email ?? 'null'}');
    
    currentUser.value = currentFirebaseUser == null 
        ? null 
        : AppUser.fromFirebaseUser(currentFirebaseUser);
    
    // Listen for changes
    _auth.authStateChanges().listen((firebaseUser) {
      debugPrint('🔷 AuthService: Auth state changed');
      debugPrint('🔷 AuthService: New user: ${firebaseUser?.email ?? 'null'}');
      debugPrint('🔷 AuthService: User UID: ${firebaseUser?.uid ?? 'null'}');
      
      currentUser.value = firebaseUser == null 
          ? null 
          : AppUser.fromFirebaseUser(firebaseUser);
      
      debugPrint('🔷 AuthService: currentUser.value updated to: ${currentUser.value?.email ?? 'null'}');
    });
  }

  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Google sign-in (popup, web) ---
  Future<void> signInWithGoogle() {
    debugPrint('🟢 Google Sign-In: Starting...');
    try {
      debugPrint('🟢 Google Sign-In: Attempting popup...');
      return _auth.signInWithPopup(GoogleAuthProvider());
    } catch (e) {
      debugPrint('🟢 Google Sign-In: Popup failed, trying redirect. Error: $e');
      return _auth.signInWithRedirect(GoogleAuthProvider());
    }
  }

  // --- Passwordless email-link sign-in ---
  bool isSignInWithEmailLink(String link) {
    final result = _auth.isSignInWithEmailLink(link);
    debugPrint('📧 Email Link Check: Is email link? $result');
    debugPrint('📧 Email Link Check: Link: $link');
    return result;
  }

  Future<void> sendSignInLinkToEmail(
    String email,
    ActionCodeSettings actionCodeSettings,
  ) {
    debugPrint('📧 Sending sign-in link to email: $email');
    debugPrint('📧 ActionCodeSettings URL: ${actionCodeSettings.url}');
    debugPrint('📧 ActionCodeSettings handleInApp: ${actionCodeSettings.handleCodeInApp}');
    return _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  Future<UserCredential> signInWithEmailLink(String email, String link) {
    debugPrint('📧 Signing in with email link');
    debugPrint('📧 Email: $email');
    debugPrint('📧 Link: $link');
    return _auth.signInWithEmailLink(email: email, emailLink: link);
  }

  Future<void> signOut() {
    debugPrint('🚪 Signing out...');
    return _auth.signOut();
  }
}