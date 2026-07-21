import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around Firebase's User so the rest of the app doesn't
/// depend directly on the firebase_auth package.
class AppUser {
  final String uid;
  final String? email;
  final String? name;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    this.email,
    this.name,
    this.photoUrl,
  });

  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}