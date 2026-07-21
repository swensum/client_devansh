import 'package:flutter/foundation.dart';

class AppUser {
  final String name;
  final String phone;

  const AppUser({required this.name, required this.phone});
}
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final ValueNotifier<AppUser?> currentUser = ValueNotifier(null);

  bool get isSignedIn => currentUser.value != null;

  void signIn({required String name, required String phone}) {
    currentUser.value = AppUser(name: name, phone: phone);
  }

  void signOut() {
    currentUser.value = null;
  }
}