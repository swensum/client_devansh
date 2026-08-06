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
  }

  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Google sign-in (redirect, web-safe) ---
  //
  // We use signInWithRedirect instead of signInWithPopup because the popup
  // flow depends on the popup window being able to postMessage back to the
  // opener (and on the opener being able to check window.closed). That
  // breaks under a Cross-Origin-Opener-Policy: same-origin header, and can
  // also misbehave with Flutter web's visibility/reload handling — both of
  // which surface as a spurious "popup-closed-by-user" error even though
  // the user did complete sign-in. Redirect doesn't have this problem.
  //
  // NOTE: this navigates the whole page away to Google and back, so there
  // is nothing meaningful to await here on web — listen to `currentUser`
  // (or authStateChanges) to know when sign-in actually completes.
  Future<void> signInWithGoogle() {
    final provider = GoogleAuthProvider()
      ..setCustomParameters({'prompt': 'select_account'});

    if (kIsWeb) {
      return _auth.signInWithRedirect(provider);
    }

    // Non-web platforms (if you ever build for them) can still use the
    // popup-style call, which maps to the native provider flow there.
    return _auth.signInWithProvider(provider);
  }

  /// Call this once, early, on any screen that can be the target of the
  /// Google redirect (i.e. AuthScreen's initState). It resolves with the
  /// signed-in user if the app just came back from a successful redirect,
  /// null if there's no pending redirect, or throws a [FirebaseAuthException]
  /// if the redirect sign-in failed — so you can surface a real error
  /// message instead of the misleading "popup closed by user" one.
  ///
  /// Note: `currentUser` / `authStateChanges` will also update on success,
  /// independently of this call — this method exists specifically so the UI
  /// can read the *error* case too.
  Future<AppUser?> checkRedirectResult() async {
    final result = await _auth.getRedirectResult();
    final user = result.user;
    return user == null ? null : AppUser.fromFirebaseUser(user);
  }

  // --- Persistence: controls "Remember me" ---
  Future<void> _applyPersistence(bool rememberMe) async {
    if (kIsWeb) {
      await _auth.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
    }
  }

  // --- Email / Password ---
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    await _applyPersistence(rememberMe);
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    await _applyPersistence(rememberMe);
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
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
