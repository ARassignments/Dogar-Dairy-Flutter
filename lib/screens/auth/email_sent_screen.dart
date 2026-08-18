import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '/components/appsnackbar.dart';
import '/screens/auth/login_screen.dart';
import '/theme/theme.dart';

class EmailSentScreen extends StatefulWidget {
  final String email;
  const EmailSentScreen({super.key, required this.email});

  @override
  State<EmailSentScreen> createState() => _EmailSentScreenState();
}

class _EmailSentScreenState extends State<EmailSentScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isResending = false;
  int _resendCooldown = 30;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    setState(() {
      _resendCooldown = 30;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      await _auth.sendPasswordResetEmail(email: widget.email);
      if (!mounted) return;

      AppSnackBar.show(
        context,
        message: 'Password reset link re-sent to ${widget.email}',
        type: AppSnackBarType.success,
      );
      _startCooldownTimer();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: e.message ?? 'Failed to resend email.',
        type: AppSnackBarType.error,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Error: ${e.toString()}',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  String maskEmail(String email, {int visibleChars = 3, String maskChar = '*'}) {
    if (email.isEmpty) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    final maskedName = name.length > visibleChars
        ? '${name.substring(0, visibleChars)}${maskChar * (name.length - visibleChars)}'
        : name;

    return '$maskedName@$domain';
  }

  void _goToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.customListBg(context),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        HugeIconsSolid.mail02,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Check Your Email",
                    style: AppTheme.textTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTheme.textLabel(context).copyWith(fontSize: 14),
                      children: [
                        const TextSpan(text: "We've sent a password reset link to\n"),
                        TextSpan(
                          text: maskEmail(widget.email),
                          style: AppTheme.textLink(context).copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: ".\nPlease follow the instructions in the email to set a new password.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FlatButton(
                    text: 'Back to Login',
                    onPressed: _goToLogin,
                  ),
                  const SizedBox(height: 16),
                  OutlineButton(
                    text: _isResending
                        ? 'Resending...'
                        : _resendCooldown > 0
                            ? 'Resend Email ($_resendCooldown s)'
                            : 'Resend Reset Link',
                    disabled: _resendCooldown > 0 || _isResending,
                    onPressed: (_resendCooldown > 0 || _isResending)
                        ? null
                        : _resendEmail,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: child,
            ),
          );
        }
        return child;
      },
    );
  }
}
