import 'dart:async';

import 'package:devansh/services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _kBg = Colors.black;
const _kSurface = Color(0xFF141414);
const _kAmber = Color.fromRGBO(245, 171, 30, 1);

enum _AuthMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = true;

  bool _googleLoading = false;
  bool _submitLoading = false;
  String? _error;
  bool _showResendVerification = false;
  bool _resendingVerification = false;

  // --- Redirect sign-in (Safari/Brave popup fallback) ---
  bool _checkingRedirectResult = true;

  bool _isPasswordResetMode = false;
  bool _resetVerifying = true;
  String? _resetOobCode;
  String? _resetEmail;
  String? _resetError;
  bool _resetSubmitting = false;
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;

  @override
  void initState() {
    super.initState();
    _checkForPasswordResetLink();
    if (!_isPasswordResetMode) {
      _checkRedirectResult();
    } else {
      _checkingRedirectResult = false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  /// Picks up the result of a signInWithRedirect() call from a previous
  /// page load (used as a fallback when popup sign-in is blocked by
  /// Safari's ITP or Brave Shields).
  Future<void> _checkRedirectResult() async {
    try {
      final credential = await AuthService.instance.getRedirectResult();
      if (!mounted) return;

      if (credential != null) {
        setState(() => _checkingRedirectResult = false);
        await _showSuccessAndReturn('Signed in successfully!');
        return;
      }

      setState(() => _checkingRedirectResult = false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _checkingRedirectResult = false;
        _error = e.message ?? 'Google sign-in failed.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _checkingRedirectResult = false);
    }
  }

  void _checkForPasswordResetLink() {
    final params = Uri.base.queryParameters;
    final mode = params['mode'];
    final oobCode = params['oobCode'];

    if (mode != 'resetPassword' || oobCode == null || oobCode.isEmpty) {
      return;
    }

    setState(() {
      _isPasswordResetMode = true;
      _resetOobCode = oobCode;
      _resetVerifying = true;
    });

    _verifyResetCode(oobCode);
  }

  Future<void> _verifyResetCode(String code) async {
    try {
      final email = await AuthService.instance.verifyPasswordResetCode(code);
      if (!mounted) return;
      setState(() {
        _resetEmail = email;
        _resetVerifying = false;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _resetError = e.code == 'expired-action-code'
            ? 'This reset link has expired. Please request a new one.'
            : e.code == 'invalid-action-code'
            ? 'This reset link is invalid or has already been used.'
            : (e.message ?? 'Could not verify this reset link.');
        _resetVerifying = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resetError = 'Could not verify this reset link.';
        _resetVerifying = false;
      });
    }
  }

  Future<void> _submitNewPassword() async {
    if (_resetSubmitting) return;

    final newPassword = _newPasswordController.text;
    final confirm = _confirmNewPasswordController.text;

    if (newPassword.length < 6) {
      setState(() => _resetError = 'Password must be at least 6 characters.');
      return;
    }
    if (newPassword != confirm) {
      setState(() => _resetError = 'Passwords do not match.');
      return;
    }

    setState(() {
      _resetSubmitting = true;
      _resetError = null;
    });

    try {
      await AuthService.instance.confirmPasswordReset(
        _resetOobCode!,
        newPassword,
      );
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _kSurface,
          title: const Text(
            'Password updated',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Your password has been changed. You can now sign in with your new password.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Continue',
                style: TextStyle(color: _kAmber, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );

      if (!mounted) return;
      setState(() {
        _isPasswordResetMode = false;
        _resetOobCode = null;
        _resetEmail = null;
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
        _mode = _AuthMode.signIn;
      });
      context.go('/auth');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(
        () => _resetError = e.message ?? 'Could not update your password.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _resetError = 'Could not update your password.');
    } finally {
      if (mounted) setState(() => _resetSubmitting = false);
    }
  }

  void _switchMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _error = null;
      _showResendVerification = false;
    });
  }

  /// After a successful sign-in, return the user to wherever they came from
  /// instead of always dumping them on the home route.
  void _returnAfterSignIn() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  /// Shows a brief success snackbar, then returns the user to where they
  /// came from. Shared by Google popup, Google redirect, and email sign-in.
  Future<void> _showSuccessAndReturn(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _kSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 700));
    _returnAfterSignIn();
  }

  Future<void> _signInWithGoogle() async {
    if (_googleLoading) return;
    setState(() {
      _googleLoading = true;
      _error = null;
      _showResendVerification = false;
    });
    try {
      await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      // If this fell back to signInWithRedirect(), the page is about to
      // navigate away and nothing below runs — the result is picked up by
      // _checkRedirectResult() on next load.
      await _showSuccessAndReturn('Signed in successfully!');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.message ?? 'Google sign-in failed.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Google sign-in was cancelled or failed.');
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  String? _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      return 'Enter a valid email address.';
    }
    if (password.isEmpty || password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (_mode == _AuthMode.signUp &&
        password != _confirmPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_submitLoading) return;

    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final wasSignIn = _mode == _AuthMode.signIn;

    setState(() {
      _submitLoading = true;
      _error = null;
      _showResendVerification = false;
    });

    try {
      if (wasSignIn) {
        await AuthService.instance.signInWithEmailPassword(
          email,
          password,
          rememberMe: _rememberMe,
        );
        if (!mounted) return;
        await _showSuccessAndReturn('Signed in successfully!');
      } else {
        await AuthService.instance.signUpWithEmailPassword(
          email,
          password,
          rememberMe: _rememberMe,
        );
        if (!mounted) return;
        // Don't treat this as a completed sign-up yet — the dialog only
        // reports success (and navigates away) once the email is verified.
        await _showVerifyEmailDialog(email);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyAuthError(e.code) ?? e.message;
        _showResendVerification = e.code == 'email-not-verified';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _submitLoading = false);
    }
  }

  /// Resends a verification email after a blocked sign-in attempt, using
  /// whatever's currently in the email/password fields.
  Future<void> _resendVerificationFromSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty || _resendingVerification) return;

    setState(() => _resendingVerification = true);
    try {
      await AuthService.instance.resendVerificationEmail(email, password);
      if (!mounted) return;
      setState(() {
        _error = 'Verification email resent. Check your inbox.';
        _showResendVerification = false;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyAuthError(e.code) ?? e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not resend verification email.');
    } finally {
      if (mounted) setState(() => _resendingVerification = false);
    }
  }

  Future<void> _showVerifyEmailDialog(String email) async {
    Timer? pollTimer;
    bool checking = false;
    bool resending = false;
    bool closed = false;
    String? dialogError;
    String? dialogInfo;
    bool verified = false;

    void closeDialog(BuildContext dialogContext) {
      if (closed) return;
      closed = true;
      pollTimer?.cancel();
      Navigator.of(dialogContext).pop();
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> checkNow({bool reportIfNotVerified = false}) async {
              if (checking || closed) return;
              checking = true;
              if (!closed) setDialogState(() => dialogError = null);

              final isVerified = await AuthService.instance
                  .reloadAndCheckEmailVerified();
              if (!mounted || closed || !dialogContext.mounted) return;

              if (isVerified) {
                verified = true;

                closeDialog(dialogContext);
                return;
              }

              checking = false;
              if (reportIfNotVerified) {
                setDialogState(() {
                  dialogError =
                      "Still not verified. Click the link in the email, then try again.";
                });
              }
            }

            pollTimer ??= Timer.periodic(
              const Duration(seconds: 3),
              (_) => checkNow(),
            );

            return PopScope(
              canPop: false,
              child: AlertDialog(
                backgroundColor: _kSurface,
                insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                title: const Text(
                  'Verify your email',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
                content: SizedBox(
                  width: 260,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We sent a verification link to $email. please check you inbox and click the link to verify.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _kAmber,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Text(
                            'Waiting for verification…',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (dialogError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          dialogError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (dialogInfo != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          dialogInfo!,
                          style: const TextStyle(color: _kAmber, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                actions: [
                  TextButton(
                    onPressed: resending
                        ? null
                        : () async {
                            setDialogState(() {
                              resending = true;
                              dialogInfo = null;
                              dialogError = null;
                            });
                            try {
                              await AuthService.instance
                                  .sendEmailVerification();
                              if (closed) return;
                              setDialogState(
                                () => dialogInfo = 'Verification email resent.',
                              );
                            } catch (_) {
                              if (closed) return;
                              setDialogState(
                                () => dialogError =
                                    'Could not resend the email. Try again shortly.',
                              );
                            } finally {
                              if (!closed) {
                                setDialogState(() => resending = false);
                              }
                            }
                          },
                    child: Text(
                      resending ? 'Sending…' : 'Resend email',
                      style: const TextStyle(
                        color: _kAmber,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    pollTimer?.cancel();
    if (!mounted) return;

    if (verified) {
      setState(() => _mode = _AuthMode.signIn);
      await _showSuccessAndReturn("Account verified — you're in!");
    } else {
      // Not verified — sign-up is NOT considered complete for this user.
      setState(() {
        _mode = _AuthMode.signIn;
        _error =
            'Email not verified, so the account isn\'t active yet. '
            'Sign in once you\'ve verified, or sign up again.';
      });
    }
  }

  String? _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email. Try creating one instead.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with that email. Try signing in instead.';
      case 'weak-password':
        return 'That password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'email-not-verified':
        return 'Please verify your email before signing in — check your inbox for the link.';
      default:
        return null;
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final controller = TextEditingController(
      text: _emailController.text.trim(),
    );
    bool sending = false;
    String? localError;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _kSurface,
              title: const Text(
                'Reset your password',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your account email. We\'ll send a link that opens right back '
                    'here so you can set a new password.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'you@example.com',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ),
                  if (localError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      localError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (sending) return;

                    final messenger = ScaffoldMessenger.of(this.context);

                    final email = controller.text.trim();
                    if (email.isEmpty || !email.contains('@')) {
                      setDialogState(
                        () => localError = 'Enter a valid email address.',
                      );
                      return;
                    }

                    setDialogState(() {
                      sending = true;
                      localError = null;
                    });

                    try {
                      await AuthService.instance.sendPasswordResetEmail(email);

                      if (!context.mounted) return;

                      context.pop();

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Reset link sent to $email. Check your inbox (and spam folder).',
                          ),
                          backgroundColor: _kSurface,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      setDialogState(() {
                        localError = e.code == 'user-not-found'
                            ? 'No account found with that email.'
                            : (e.message ?? 'Could not send reset email.');
                        sending = false;
                      });
                    } catch (e) {
                      setDialogState(() {
                        localError = 'Could not send reset email.';
                        sending = false;
                      });
                    }
                  },
                  child: sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _kAmber,
                          ),
                        )
                      : const Text(
                          'Send Reset Link',
                          style: TextStyle(color: _kAmber),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isPasswordResetMode) {
      return _buildResetPasswordScreen();
    }

    if (_checkingRedirectResult) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: CircularProgressIndicator(color: _kAmber)),
      );
    }

    final isSignIn = _mode == _AuthMode.signIn;

    return Scaffold(
      backgroundColor: _kBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSignIn ? 'Sign in' : 'Create account',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSignIn
                      ? 'Sign in to place and track your orders'
                      : 'Create an account to get started',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // --- Google ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: _googleLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const _GoogleGlyph(),
                    label: Text(
                      _googleLoading ? 'Signing in…' : 'Continue with Google',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Email ---
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration('you@example.com'),
                ),
                const SizedBox(height: 12),

                // --- Password ---
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _submit(),
                  decoration: _fieldDecoration('Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                // --- Confirm password (sign up only) ---
                if (!isSignIn) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _submit(),
                    decoration: _fieldDecoration('Confirm password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // --- Remember me / Forgot password ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v ?? true),
                              activeColor: _kAmber,
                              checkColor: Colors.black,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Remember me',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSignIn)
                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: _kAmber,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAmber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: _submitLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            isSignIn ? 'Sign In' : 'Create Account',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                if (_showResendVerification) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _resendingVerification
                          ? null
                          : _resendVerificationFromSignIn,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _resendingVerification
                            ? 'Sending…'
                            : 'Resend verification email',
                        style: const TextStyle(
                          color: _kAmber,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // --- Mode switch ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSignIn
                          ? "Don't have an account? "
                          : 'Already have an account? ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _switchMode(
                        isSignIn ? _AuthMode.signUp : _AuthMode.signIn,
                      ),
                      child: Text(
                        isSignIn ? 'Sign up' : 'Sign in',
                        style: const TextStyle(
                          color: _kAmber,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetPasswordScreen() {
    return Scaffold(
      backgroundColor: _kBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _resetVerifying
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: _kAmber),
                      SizedBox(height: 16),
                      Text(
                        'Verifying link…',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  )
                : (_resetEmail == null)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _resetError ?? 'This reset link is invalid.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordResetMode = false;
                            _mode = _AuthMode.signIn;
                          });
                          context.go('/auth');
                        },
                        child: const Text(
                          'Back to sign in',
                          style: TextStyle(color: _kAmber),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Set new password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a new password for $_resetEmail',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _fieldDecoration('New password').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white.withValues(alpha: 0.4),
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmNewPasswordController,
                        obscureText: _obscureConfirmNewPassword,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => _submitNewPassword(),
                        decoration: _fieldDecoration('Confirm new password')
                            .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmNewPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirmNewPassword =
                                      !_obscureConfirmNewPassword,
                                ),
                              ),
                            ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitNewPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kAmber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: _resetSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Update Password',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                      if (_resetError != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _resetError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
