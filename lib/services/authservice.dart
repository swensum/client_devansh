import 'package:devansh/models/authmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Singleton wrapper around FirebaseAuth.
class AuthService {
 AuthService._internal() {
  final currentFirebaseUser = _auth.currentUser;
  currentUser.value = currentFirebaseUser == null
      ? null
      : AppUser.fromFirebaseUser(currentFirebaseUser);

  _auth.authStateChanges().listen((firebaseUser) {
    currentUser.value = firebaseUser == null
        ? null
        : AppUser.fromFirebaseUser(firebaseUser);
  });

  _checkRedirectResult();
}

Future<void> _checkRedirectResult() async {
  try {
    final result = await _auth.getRedirectResult();
    if (result.user != null) {
      debugPrint('[Auth] Redirect sign-in success: uid=${result.user!.uid}');
    }
  } on FirebaseAuthException catch (e) {
    debugPrint('[Auth] Redirect sign-in error: ${e.code} ${e.message}');
  }
}

  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Google sign-in (simple popup-only approach) ---
  Future<void> signInWithGoogle() async {
  final provider = GoogleAuthProvider()
    ..setCustomParameters({'prompt': 'select_account'});

  debugPrint('[Auth] signInWithGoogle: starting redirect');
  await _auth.signInWithRedirect(provider);
  // Browser navigates away here — result is picked up after redirect back.
}

  // --- Persistence: controls "Remember me" ---
  Future<void> _applyPersistence(bool rememberMe) async {
    if (kIsWeb) {
      await _auth.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
    }
  }

  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    await _applyPersistence(rememberMe);
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null && !credential.user!.emailVerified) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email before signing in.',
      );
    }

    return credential;
  }

  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    await _applyPersistence(rememberMe);
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
    return credential;
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> resendVerificationEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null && !credential.user!.emailVerified) {
      await credential.user!.sendEmailVerification();
    }
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) {
    final resetUrl = Uri.base.replace(queryParameters: {});
    final actionCodeSettings = ActionCodeSettings(
      url: resetUrl.toString(),
      handleCodeInApp: true,
    );
    return _auth.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  Future<String> verifyPasswordResetCode(String code) {
    return _auth.verifyPasswordResetCode(code);
  }

  Future<void> confirmPasswordReset(String code, String newPassword) {
    return _auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }

  Future<void> signOut() => _auth.signOut();
}
