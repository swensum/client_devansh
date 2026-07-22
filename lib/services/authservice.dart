import 'package:devansh/models/authmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Singleton wrapper around FirebaseAuth. Exposes a ValueNotifier<AppUser?>
/// so widgets can listen with ValueListenableBuilder and rebuild
/// automatically on sign-in/sign-out.
class AuthService {
  AuthService._internal() {
    final currentFirebaseUser = _auth.currentUser;
    currentUser.value = currentFirebaseUser == null
        ? null
        : AppUser.fromFirebaseUser(currentFirebaseUser);

    _auth.authStateChanges().listen((firebaseUser) {
      currentUser.value =
          firebaseUser == null ? null : AppUser.fromFirebaseUser(firebaseUser);
    });
  }

  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Google sign-in (popup, web) ---
  Future<void> signInWithGoogle() {
    return _auth.signInWithPopup(GoogleAuthProvider());
  }

  // --- Passwordless email-link sign-in ---
  bool isSignInWithEmailLink(String link) => _auth.isSignInWithEmailLink(link);

  Future<void> sendSignInLinkToEmail(
    String email,
    ActionCodeSettings actionCodeSettings,
  ) {
    return _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  Future<UserCredential> signInWithEmailLink(String email, String link) {
    return _auth.signInWithEmailLink(email: email, emailLink: link);
  }

  Future<void> signOut() => _auth.signOut();
}