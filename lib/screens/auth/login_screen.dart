import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/user_provider.dart';
import '/screens/auth/forgot_password_screen.dart';
import '/components/appsnackbar.dart';
import '/utils/session_manager.dart';
import '/screens/auth/signup_screen.dart';
import '/theme/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isFormValid = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool get _isFormDisabled => _isLoading || !_isFormValid;
  FirebaseAuth _auth = FirebaseAuth.instance;

  TextInputType _keyboardType = TextInputType.text;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
    _emailController.addListener(() {
      _updateKeyboardType();
      _validateForm();
    });
    _passwordController.addListener(_validateForm);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateForm();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAutoLogin() async {
    final remember = await SessionManager.getRememberMe();
    final userId = await SessionManager.getUserId();
    final user = await SessionManager.getUser();

    if (remember && userId != null && user != null) {
      if (!mounted) return;
      if (MediaQuery.of(context).size.width >= 900) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => DashboardScreen(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => DashboardScreen(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
          ),
        );
      }
    }
  }

  void _updateKeyboardType() {
    final text = _emailController.text;
    final newType = text.contains('@')
        ? TextInputType.emailAddress
        : TextInputType.text;

    if (newType != _keyboardType) {
      setState(() => _keyboardType = newType);
    }
  }

  bool _validateCurrentForm() {
    final text = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final isEmail = text.contains('@');

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    final usernameRegex = RegExp(
      r'^(?=.*[A-Za-z])[A-Za-z0-9](?:[A-Za-z0-9_]{1,18}[A-Za-z0-9])?$',
    );

    final isEmailOrUsernameValid = isEmail
        ? emailRegex.hasMatch(text)
        : usernameRegex.hasMatch(text);

    final isPasswordValid = password.isNotEmpty && password.length >= 8;

    return isEmailOrUsernameValid && isPasswordValid;
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _validateCurrentForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_buildLoginForm()],
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
        } else {
          return child!;
        }
      },
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      onChanged: _validateForm,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(AppTheme.appLogo(context), height: 100, width: 100),
            SizedBox(height: 40),
            Text(
              "Login to Dogar Dairy",
              style: AppTheme.textTitle(context),
              textAlign: TextAlign.start,
            ),

            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Email / Username*',
                hintText: 'e.g. david@example.com or david123',
                counter: const SizedBox.shrink(),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                  child: Icon(HugeIconsSolid.mail02),
                ),
                suffixIcon: _isLoading
                    ? null
                    : _emailController.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: Icon(HugeIconsStroke.cancel02),
                          onPressed: () {
                            _emailController.clear(); // Clear the text field
                          },
                        ),
                      )
                    : null,
              ),
              style: AppInputDecoration.inputTextStyle(context),
              keyboardType: _keyboardType,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email or username';
                }

                final isEmail = value.contains('@');

                // Email regex
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );

                // Username regex (letters, numbers, underscores, 3–20 chars)
                final usernameRegex = RegExp(
                  r'^(?=.*[A-Za-z])[A-Za-z0-9](?:[A-Za-z0-9_]{1,18}[A-Za-z0-9])?$',
                );

                if (isEmail && !emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                } else if (!isEmail && !usernameRegex.hasMatch(value)) {
                  return 'Username must be 3–20 characters (letters, numbers, _)';
                }
                return null;
              },
              maxLength: 40,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Password*',
                hintText: 'e.g. dav*****',
                counter: const SizedBox.shrink(),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                  child: Icon(HugeIconsSolid.lockKey),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? HugeIconsSolid.viewOff
                          : HugeIconsSolid.eye,
                    ),
                    splashRadius: 20, // Smaller tap area
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              style: AppInputDecoration.inputTextStyle(context),
              obscureText: _obscurePassword,
              obscuringCharacter: '•',
              keyboardType: TextInputType.visiblePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                } else if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                return null;
              },
              maxLength: 20,
            ),

            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: AppTheme.checkBox(context),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      onChanged: (bool? value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                        // You can add additional logic here
                      },
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _rememberMe = !_rememberMe;
                        });
                      },
                      child: Text(
                        'Remember Me',
                        style: AppTheme.textLabel(context),
                      ),
                    ),
                  ],
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTheme.textLabel(context),
                    children: [
                      TextSpan(
                        text: 'Forgot Password?',
                        style: AppTheme.textLink(context),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  ForgotPasswordScreen(),
                              transitionsBuilder: (_, a, __, c) =>
                                  FadeTransition(opacity: a, child: c),
                            ),
                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            FlatButton(
              text: 'Continue',
              disabled: !_isFormValid || _isLoading,
              onPressed: (_isFormValid && !_isLoading)
                  ? () async {
                      if (!_validateCurrentForm()) {
                        return; // Use validation method
                      }
                      await _submitLoginForm();
                    }
                  : null,
              loading: _isLoading,
            ),
            SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTheme.textLabel(context),
                children: [
                  TextSpan(text: 'Don’t have an account? '),
                  TextSpan(
                    text: 'Register',
                    style: AppTheme.textLink(context),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => SignupScreen(),
                          transitionsBuilder: (_, a, __, c) =>
                              FadeTransition(opacity: a, child: c),
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitLoginForm() async {
    if (!_validateCurrentForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      // Clear Old User Data
      // ref.read(userProvider.notifier).clearUser();

      // Firebase Sign In
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await _auth.signOut();
          AppSnackBar.show(
            context,
            message: "User record not found",
            type: AppSnackBarType.error,
          );
          return;
        }

        final data = userDoc.data() as Map<String, dynamic>;

        // Check user blocked
        if (data['status'] == false) {
          await _auth.signOut();
          AppSnackBar.show(
            context,
            message: "This user is blocked by admin",
            type: AppSnackBarType.error,
          );
          return;
        }

        // Important — Fetch into Riverpod Provider
        // await ref.read(userProvider.notifier).fetchUser();

        // Navigate Based on Role
        final role = data['role'] ?? 'user';

        if (role == "user") {
          // Save session
          await SessionManager.saveUserSession(
            user.uid,
            data,
            _rememberMe,
            _passwordController.text.trim(),
          );

          // Navigate to home
          if (mounted) {
            AppSnackBar.show(
              context,
              message: 'Login successful!',
              type: AppSnackBarType.success,
            );
            if (MediaQuery.of(context).size.width >= 900) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => DashboardScreen(),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => DashboardScreen(),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
              );
            }
          }
        }
      } else {
        setState(() {
          AppSnackBar.show(
            context,
            message: "Login failed (-_-)",
            type: AppSnackBarType.error,
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      AppSnackBar.show(
        context,
        message: _getErrorMessage(e),
        type: AppSnackBarType.error,
      );
      _emailController.clear();
      _passwordController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'Sign in failed. Please try again.';
    }
  }
}
