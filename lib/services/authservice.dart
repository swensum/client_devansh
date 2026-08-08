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

  // --- Google sign-in (web) ---
  //
  // Popup sign-in relies on a hidden iframe on the Firebase authDomain
  // relaying the credential back to this tab via IndexedDB. Safari (ITP)
  // and Brave (Shields) block that cross-origin storage access by default,
  // so the popup finishes on Google's side but the result never makes it
  // back — Firebase then times out and reports `popup-closed-by-user` even
  // though the user actually completed the sign-in. Redirect sign-in
  // doesn't depend on that relay, so we fall back to it when popup fails
  // for that class of reason.
  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..setCustomParameters({'prompt': 'select_account'});

    if (!kIsWeb) {
      await _auth.signInWithPopup(provider);
      return;
    }

    try {
      await _auth.signInWithPopup(provider);
    } on FirebaseAuthException catch (e) {
      if (_shouldFallBackToRedirect(e.code)) {
        await _auth.signInWithRedirect(provider);
        // Execution ends here — the page will navigate away to Google
        // and back. The result is picked up by getRedirectResult() on
        // the next app load (see AuthScreen.initState).
        return;
      }
      rethrow;
    }
  }

  bool _shouldFallBackToRedirect(String code) {
    switch (code) {
      case 'auth/popup-closed-by-user':
      case 'auth/popup-blocked':
      case 'auth/cancelled-popup-request':
      case 'auth/web-storage-unsupported':
      case 'auth/operation-not-supported-in-this-environment':
        return true;
      default:
        return false;
    }
  }

  /// Call once on app/screen startup (web only) to pick up the result of a
  /// signInWithRedirect() call from a previous page load. Returns the
  /// UserCredential if a redirect sign-in just completed, or null if there
  /// was no pending redirect result to process.
  Future<UserCredential?> getRedirectResult() async {
    if (!kIsWeb) return null;
    final result = await _auth.getRedirectResult();
    if (result.user == null) return null;
    return result;
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

  /// Signs in with email/password. Unverified accounts are immediately
  /// signed back out and rejected with a synthetic `email-not-verified`
  /// error code — an unverified account can't be used to sign in.
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

  /// Creates the account and immediately sends a verification email. The
  /// account exists in Firebase after this returns, but AuthScreen treats
  /// sign-up as incomplete until the email is verified — see the
  /// verify-email dialog flow there. If the user never verifies, they'll
  /// simply be rejected on their next sign-in attempt (see above) until
  /// they do.
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

  /// Resends a verification email to the currently signed-in user. Used
  /// while the "verify your email" dialog is open right after sign-up.
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
  }

  /// Reloads the current user from Firebase and reports whether their
  /// email is now verified. Returns false if nobody is signed in.
  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Resends a verification email for an account the user is NOT currently
  /// signed in to (e.g. they tried to sign in, got blocked as unverified,
  /// and want another link). Signs in just long enough to trigger the
  /// email, then signs back out — the account stays "not signed in" either
  /// way.
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
