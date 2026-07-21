import 'package:devansh/services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBg = Colors.black;
const _kSurface = Color(0xFF141414);
const _kAmber = Color.fromRGBO(245, 171, 30, 1);
const _kPendingEmailKey = 'auth_pending_email';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  bool _googleLoading = false;
  bool _emailLoading = false;
  bool _linkSent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    debugPrint('🔷 AuthScreen: initState called');
    debugPrint('🔷 AuthScreen: Current URL: ${Uri.base.toString()}');
    
    // Delay to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔷 AuthScreen: Post-frame callback - checking for email link...');
      _completeEmailLinkSignInIfPresent();
    });
  }

  @override
  void dispose() {
    debugPrint('🔷 AuthScreen: dispose called');
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _completeEmailLinkSignInIfPresent() async {
    debugPrint('📧 _completeEmailLinkSignInIfPresent: Starting...');
    
    // Get the current URL from the browser
    final currentUrl = Uri.base.toString();
    debugPrint('📧 Current URL: $currentUrl');
    
    final auth = AuthService.instance;

    // Check if this is an email link sign-in
    final isEmailLink = auth.isSignInWithEmailLink(currentUrl);
    debugPrint('📧 Is email link? $isEmailLink');
    
    if (!isEmailLink) {
      debugPrint('📧 Not an email link, returning...');
      return;
    }

    debugPrint('📧 This is an email link! Processing...');

    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString(_kPendingEmailKey);
    debugPrint('📧 Stored email from SharedPreferences: $email');

    // If we don't have the email stored, prompt the user for it
    if (email == null || email.isEmpty) {
      debugPrint('📧 No email stored, checking URL for email parameter...');
      
      // Check if the URL contains the email parameter
      final uri = Uri.parse(currentUrl);
      final emailFromUrl = uri.queryParameters['email'];
      debugPrint('📧 Email from URL query parameter: $emailFromUrl');
      
      if (emailFromUrl != null && emailFromUrl.isNotEmpty) {
        email = emailFromUrl;
        debugPrint('📧 Using email from URL: $email');
      } else {
        debugPrint('📧 No email in URL, prompting user...');
        if (!mounted) return;
        email = await _promptForEmail();
        debugPrint('📧 User provided email: $email');
        if (email == null || email.isEmpty) {
          debugPrint('📧 No email provided by user, returning...');
          return;
        }
      }
    }

    debugPrint('📧 Proceeding with email: $email');
    await _finishEmailLinkSignIn(email, currentUrl);
  }

  Future<String?> _promptForEmail() async {
    debugPrint('📧 _promptForEmail: Showing dialog...');
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _kSurface,
        title: const Text('Confirm your email', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'you@example.com',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('📧 User cancelled email prompt');
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final email = controller.text.trim();
              debugPrint('📧 User entered email: $email');
              if (email.isNotEmpty && email.contains('@')) {
                Navigator.pop(context, email);
              } else {
                debugPrint('📧 Invalid email entered: $email');
              }
            },
            child: const Text('Confirm', style: TextStyle(color: _kAmber)),
          ),
        ],
      ),
    );
  }

  Future<void> _finishEmailLinkSignIn(String email, String link) async {
    debugPrint('📧 _finishEmailLinkSignIn: Starting...');
    debugPrint('📧 Email: $email');
    debugPrint('📧 Link: $link');
    
    try {
      debugPrint('📧 Attempting to sign in with email link...');
      final result = await AuthService.instance.signInWithEmailLink(email, link);
      debugPrint('📧 Sign-in successful!');
      debugPrint('📧 User: ${result.user?.email}');
      debugPrint('📧 UID: ${result.user?.uid}');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPendingEmailKey);
      debugPrint('📧 Removed pending email from SharedPreferences');
      
      // The auth state change listener in AuthService will handle the navigation
      // Clear any error if present
      if (mounted) {
        setState(() {
          _error = null;
          _linkSent = false;
        });
        debugPrint('📧 State cleared after successful sign-in');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException in _finishEmailLinkSignIn:');
      debugPrint('❌ Code: ${e.code}');
      debugPrint('❌ Message: ${e.message}');
      debugPrint('❌ Stack trace: ${e.stackTrace}');
      
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'That sign-in link is invalid or expired.';
      });
    } catch (e) {
      debugPrint('❌ Unexpected error in _finishEmailLinkSignIn: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong completing sign-in.';
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    debugPrint('🟢 _signInWithGoogle: Starting...');
    
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    
    try {
      debugPrint('🟢 Calling AuthService.signInWithGoogle()...');
      await AuthService.instance.signInWithGoogle();
      debugPrint('🟢 Google sign-in completed successfully!');
      // No manual navigation — router redirect handles it.
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException in Google sign-in:');
      debugPrint('❌ Code: ${e.code}');
      debugPrint('❌ Message: ${e.message}');
      
      if (mounted) {
        setState(() => _error = e.message ?? 'Google sign-in failed.');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in Google sign-in: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        setState(() => _error = 'Google sign-in was cancelled or failed.');
      }
    } finally {
      debugPrint('🟢 Google sign-in flow completed');
      if (mounted) {
        setState(() => _googleLoading = false);
      }
    }
  }

  Future<void> _sendEmailLink() async {
    final email = _emailController.text.trim();
    debugPrint('📧 _sendEmailLink: Starting with email: $email');
    
    if (email.isEmpty || !email.contains('@')) {
      debugPrint('📧 Invalid email: $email');
      setState(() => _error = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _emailLoading = true;
      _error = null;
    });

    try {
      // Build the URL for the email link
      final baseUrl = Uri.base;
      debugPrint('📧 Base URL: $baseUrl');
      
      final redirectUrl = baseUrl.replace(
        queryParameters: {
          ...baseUrl.queryParameters,
          'email': email,
        },
      );
      debugPrint('📧 Redirect URL with email param: $redirectUrl');

      final actionCodeSettings = ActionCodeSettings(
        url: redirectUrl.toString(),
        handleCodeInApp: true,
        androidPackageName: null, // Web only
        iOSBundleId: null, // Web only
      );
      
      debugPrint('📧 ActionCodeSettings:');
      debugPrint('📧   URL: ${actionCodeSettings.url}');
      debugPrint('📧   handleInApp: ${actionCodeSettings.handleCodeInApp}');

      debugPrint('📧 Sending sign-in link to email...');
      await AuthService.instance.sendSignInLinkToEmail(email, actionCodeSettings);
      debugPrint('📧 Sign-in link sent successfully!');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPendingEmailKey, email);
      debugPrint('📧 Saved email to SharedPreferences: $email');

      if (!mounted) return;
      setState(() {
        _linkSent = true;
        _error = null;
      });
      debugPrint('📧 State updated: _linkSent = true');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException in _sendEmailLink:');
      debugPrint('❌ Code: ${e.code}');
      debugPrint('❌ Message: ${e.message}');
      debugPrint('❌ Stack trace: ${e.stackTrace}');
      
      if (mounted) {
        setState(() => _error = e.message ?? 'Could not send sign-in link.');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in _sendEmailLink: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        setState(() => _error = 'An error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _emailLoading = false);
      }
      debugPrint('📧 _sendEmailLink completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔷 AuthScreen: Building...');
    debugPrint('🔷 State: _linkSent=$_linkSent, _error=$_error');
    
    return Scaffold(
      backgroundColor: _kBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sign in',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to place and track your orders',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 14),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _googleLoading ? null : _signInWithGoogle,
                    icon: _googleLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const _GoogleGlyph(),
                    label: Text(_googleLoading ? 'Signing in…' : 'Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
                  ],
                ),
                const SizedBox(height: 20),
                if (_linkSent) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _kAmber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kAmber.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.mark_email_read_outlined, color: _kAmber, size: 28),
                        const SizedBox(height: 10),
                        const Text(
                          'Check your inbox',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'We sent a sign-in link to ${_emailController.text.trim()}. '
                          'Open it on this device to finish signing in.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            debugPrint('📧 User clicked "Try another email"');
                            setState(() => _linkSent = false);
                          },
                          child: const Text('Try another email', style: TextStyle(color: _kAmber)),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _sendEmailLink(),
                    decoration: InputDecoration(
                      hintText: 'you@example.com',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.04),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(color: _kAmber, width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _emailLoading ? null : _sendEmailLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAmber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                      child: _emailLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text('Continue with Email', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: Icon(Icons.g_mobiledata, color: Colors.white, size: 22),
    );
  }
}