import 'package:devansh/services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  // Set when the current URL is a Firebase sign-in link. We do NOT
  // auto-complete sign-in — we wait for an explicit tap on "Complete
  // Sign In" below. This protects against email security scanners
  // (Gmail/Outlook link-safety bots) that pre-visit and execute links
  // in emails, which would otherwise silently consume the one-time
  // link before the real user clicks it.
  String? _pendingLinkUrl;
  String? _detectedEmail;
  bool _completingLink = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectEmailLink();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _detectEmailLink() async {
    final currentUrl = Uri.base.toString();
    final auth = AuthService.instance;

    if (!auth.isSignInWithEmailLink(currentUrl)) return;

    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString(_kPendingEmailKey);

    if (email == null || email.isEmpty) {
      final uri = Uri.parse(currentUrl);
      email = uri.queryParameters['email'];
    }

    if (!mounted) return;
    setState(() {
      _pendingLinkUrl = currentUrl;
      _detectedEmail = email;
    });
  }

  Future<void> _completePendingLinkSignIn() async {
    if (_pendingLinkUrl == null) return;

    String? email = _detectedEmail;
    if (email == null || email.isEmpty) {
      email = await _promptForEmail();
      if (email == null || email.isEmpty) return;
    }

    setState(() {
      _completingLink = true;
      _error = null;
    });

    try {
      await AuthService.instance.signInWithEmailLink(email, _pendingLinkUrl!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPendingEmailKey);

      if (!mounted) return;
      context.go('/');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _pendingLinkUrl = null;
        _error = e.code == 'invalid-action-code' || e.code == 'expired-action-code'
            ? 'This sign-in link has already been used or has expired. '
              'This can happen if your email provider auto-scans links for '
              'safety. Please request a new one below.'
            : e.message ?? 'That sign-in link is invalid or expired.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pendingLinkUrl = null;
        _error = 'Something went wrong completing sign-in. Please request a new link.';
      });
    } finally {
      if (mounted) setState(() => _completingLink = false);
    }
  }

  Future<String?> _promptForEmail() async {
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final email = controller.text.trim();
              if (email.isNotEmpty && email.contains('@')) {
                Navigator.pop(context, email);
              }
            },
            child: const Text('Confirm', style: TextStyle(color: _kAmber)),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      context.go('/');
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Google sign-in failed.');
    } catch (e) {
      if (mounted) setState(() => _error = 'Google sign-in was cancelled or failed.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _sendEmailLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _emailLoading = true;
      _error = null;
    });

    try {
      final baseUrl = Uri.base;
      final redirectUrl = baseUrl.replace(
        queryParameters: {
          ...baseUrl.queryParameters,
          'email': email,
        },
      );

      final actionCodeSettings = ActionCodeSettings(
        url: redirectUrl.toString(),
        handleCodeInApp: true,
      );

      await AuthService.instance.sendSignInLinkToEmail(email, actionCodeSettings);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPendingEmailKey, email);

      if (!mounted) return;
      setState(() {
        _linkSent = true;
        _error = null;
      });
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Could not send sign-in link.');
    } catch (e) {
      if (mounted) setState(() => _error = 'An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _emailLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

                // --- Pending email-link confirmation card ---
                if (_pendingLinkUrl != null) ...[
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
                        const Icon(Icons.link, color: _kAmber, size: 28),
                        const SizedBox(height: 10),
                        const Text(
                          'Sign-in link detected',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _detectedEmail != null
                              ? 'Tap below to finish signing in as $_detectedEmail.'
                              : 'Tap below to finish signing in.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _completingLink ? null : _completePendingLinkSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kAmber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                            ),
                            child: _completingLink
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : const Text('Complete Sign In', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                ],

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
                          onPressed: () => setState(() => _linkSent = false),
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