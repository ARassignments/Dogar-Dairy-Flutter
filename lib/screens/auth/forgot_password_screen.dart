import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '/components/appsnackbar.dart';
import '/screens/auth/email_sent_screen.dart';
import '/theme/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isFormValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateForm();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  bool _validateCurrentForm() {
    final text = _emailController.text.trim();
    if (text.isEmpty) return false;

    final isEmail = text.contains('@');
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    final usernameRegex = RegExp(
      r'^(?=.*[A-Za-z])[A-Za-z0-9](?:[A-Za-z0-9_]{1,18}[A-Za-z0-9])?$',
    );

    return isEmail ? emailRegex.hasMatch(text) : usernameRegex.hasMatch(text);
  }

  void _validateForm() {
    final isValid = _validateCurrentForm();
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  /// Resolves username to email if the user entered a username instead of an email.
  Future<String?> _resolveEmail(String input) async {
    final trimmed = input.trim();
    if (trimmed.contains('@')) {
      return trimmed;
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Users')
          .where('username', isEqualTo: trimmed)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        snapshot = await _firestore
            .collection('Users')
            .where('name', isEqualTo: trimmed)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        final email = data['email'] as String?;
        if (email != null && email.isNotEmpty) {
          return email;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error resolving username: $e");
      return null;
    }
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_validateCurrentForm()) {
      AppSnackBar.show(
        context,
        message: 'Please enter a valid email address or username',
        type: AppSnackBarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final input = _emailController.text.trim();
      String? targetEmail = input;

      // 1. Resolve email if username was provided
      if (!input.contains('@')) {
        targetEmail = await _resolveEmail(input);
        if (targetEmail == null) {
          if (!mounted) return;
          AppSnackBar.show(
            context,
            message: 'No account found for username "$input".',
            type: AppSnackBarType.error,
          );
          return;
        }
      }

      // 2. Send Firebase Password Reset Email
      await _auth.sendPasswordResetEmail(email: targetEmail);

      if (!mounted) return;

      AppSnackBar.show(
        context,
        message: 'Password reset link sent successfully!',
        type: AppSnackBarType.success,
      );

      // 3. Navigate to Email Sent confirmation screen
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => EmailSentScreen(email: targetEmail!),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "FirebaseAuthException in forgot password: ${e.code} - ${e.message}",
      );
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: _getErrorMessage(e),
        type: AppSnackBarType.error,
      );
    } catch (e) {
      debugPrint("General error in forgot password: $e");
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Failed to send reset email: ${e.toString()}',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account registered with this email.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'too-many-requests':
        return 'Too many requests. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ??
            'Failed to send password reset email. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [_buildForgotForm()],
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

  Widget _buildForgotForm() {
    return Form(
      key: _formKey,
      onChanged: _validateForm,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                AppTheme.appLogo(context),
                height: 100,
                width: 100,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.lock_reset_rounded, size: 80),
              ),
            ),
            const SizedBox(height: 32),
            Text("Forgot Password", style: AppTheme.textTitle(context)),
            const SizedBox(height: 12),
            Text(
              "Enter your registered email or username and we'll send you a password reset link to recover your account.",
              style: AppTheme.textLabel(context),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              textInputAction: TextInputAction.done,
              enabled: !_isLoading,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Email Address / Username *',
                hintText: 'e.g. david@example.com or david123',
                counter: const SizedBox.shrink(),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 8.0),
                  child: Icon(HugeIconsSolid.mail02),
                ),
                suffixIcon: _isLoading
                    ? null
                    : _emailController.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: const Icon(HugeIconsStroke.cancel02),
                          onPressed: () {
                            _emailController.clear();
                            _validateForm();
                          },
                        ),
                      )
                    : null,
              ),
              style: AppInputDecoration.inputTextStyle(context),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email or username';
                }
                final trimmed = value.trim();
                final isEmail = trimmed.contains('@');
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );
                final usernameRegex = RegExp(
                  r'^(?=.*[A-Za-z])[A-Za-z0-9](?:[A-Za-z0-9_]{1,18}[A-Za-z0-9])?$',
                );

                if (isEmail && !emailRegex.hasMatch(trimmed)) {
                  return 'Please enter a valid email address';
                } else if (!isEmail && !usernameRegex.hasMatch(trimmed)) {
                  return 'Username must be 3–20 characters';
                }
                return null;
              },
              maxLength: 40,
              onFieldSubmitted: (_) {
                if (_isFormValid && !_isLoading) {
                  _submitForm();
                }
              },
            ),
            const SizedBox(height: 24),
            FlatButton(
              text: 'Send Reset Link',
              disabled: !_isFormValid || _isLoading,
              onPressed: (_isFormValid && !_isLoading)
                  ? () async {
                      await _submitForm();
                    }
                  : null,
              loading: _isLoading,
            ),
            const SizedBox(height: 16),
            OutlineButton(
              text: 'Back to Login',
              disabled: _isLoading,
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
            ),
          ],
        ),
      ),
    );
  }
}
