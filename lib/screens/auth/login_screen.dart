import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '/components/appsnackbar.dart';
import '/providers/user_provider.dart';
import '/screens/auth/forgot_password_screen.dart';
import '/screens/auth/signup_screen.dart';
import '/screens/dashboard_screen.dart';
import '/theme/theme.dart';
import '/utils/session_manager.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Google OAuth Client IDs
  static const String _webClientId =
      '989609807796-33tolfbcena061k9ltqopktnjtirjc0r.apps.googleusercontent.com';
  static const String _androidClientId =
      '989609807796-i8rvld2qnvcpff3n070t0k116nab1q1m.apps.googleusercontent.com';
  static const String _iosClientId =
      '989609807796-s9amlis9jatdhntmvovlfub3jlhitisi.apps.googleusercontent.com';

  String get _currentGoogleClientId {
    if (kIsWeb) return _webClientId;
    return Theme.of(context).platform == TargetPlatform.iOS
        ? _iosClientId
        : _androidClientId;
  }

  bool _isFormValid = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  TextInputType _keyboardType = TextInputType.text;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _googleSignIn.initialize(serverClientId: _webClientId);
    }
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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkAutoLogin() async {
    final remember = await SessionManager.getRememberMe();
    final userId = await SessionManager.getUserId();
    final user = await SessionManager.getUser();

    if (remember && userId != null && user != null) {
      if (!mounted) return;
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const DashboardScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
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
    final isValid = _validateCurrentForm();
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
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
                children: [_buildLoginForm()],
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

  Widget _buildLoginForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      onChanged: _validateForm,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              AppTheme.appLogo(context),
              height: 100,
              width: 100,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.local_drink_rounded, size: 80),
            ),
            const SizedBox(height: 32),
            Text(
              "Login to Dogar Dairy",
              style: AppTheme.textTitle(context),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),

            // Email or Username Input
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              textInputAction: TextInputAction.next,
              enabled: !_isLoading && !_isGoogleLoading,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Email / Username*',
                hintText: 'e.g. david@example.com or david123',
                counter: const SizedBox.shrink(),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 8.0),
                  child: Icon(HugeIconsSolid.mail02),
                ),
                suffixIcon: (_isLoading || _isGoogleLoading)
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
              keyboardType: _keyboardType,
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
                  return 'Username must be 3–20 characters (letters, numbers, _)';
                }
                return null;
              },
              maxLength: 40,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ),
            const SizedBox(height: 16),

            // Password Input
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              textInputAction: TextInputAction.done,
              enabled: !_isLoading && !_isGoogleLoading,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Password*',
                hintText: 'e.g. dav*****',
                counter: const SizedBox.shrink(),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 8.0),
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
                    splashRadius: 20,
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
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your password';
                } else if (value.trim().length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                return null;
              },
              maxLength: 20,
              onFieldSubmitted: (_) {
                if (_isFormValid && !_isLoading && !_isGoogleLoading) {
                  _submitLoginForm();
                }
              },
            ),

            const SizedBox(height: 16),
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
                      onChanged: (_isLoading || _isGoogleLoading)
                          ? null
                          : (bool? value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: (_isLoading || _isGoogleLoading)
                          ? null
                          : () {
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
                        style: AppTheme.textLink(
                          context,
                        ).copyWith(fontSize: 13),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (_isLoading || _isGoogleLoading) return;
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const ForgotPasswordScreen(),
                                transitionsBuilder: (_, a, __, c) =>
                                    FadeTransition(opacity: a, child: c),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Email/Password Submit Button
            FlatButton(
              text: 'Continue',
              disabled: !_isFormValid || _isLoading || _isGoogleLoading,
              onPressed: (_isFormValid && !_isLoading && !_isGoogleLoading)
                  ? () async {
                      await _submitLoginForm();
                    }
                  : null,
              loading: _isLoading,
            ),
            const SizedBox(height: 20),

            // OR Divider
            Row(
              children: [
                Expanded(child: Divider(color: AppTheme.dividerBg(context))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "OR",
                    style: AppTheme.textLabel(context).copyWith(
                      fontSize: 12,
                      fontFamily: AppFontFamily.poppinsMedium,
                      color: isDark ? AppColor.neutral_50 : AppColor.neutral_40,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppTheme.dividerBg(context))),
              ],
            ),
            const SizedBox(height: 20),

            // Google Sign-In Button
            InkWell(
              onTap: (_isLoading || _isGoogleLoading)
                  ? null
                  : _signInWithGoogle,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColor.neutral_90 : AppColor.neutral_5,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColor.neutral_80 : AppColor.neutral_20,
                    width: 1,
                  ),
                ),
                child: _isGoogleLoading
                    ? Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.white : AppColor.black,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _GoogleLogo(size: 22),
                          const SizedBox(width: 12),
                          Text(
                            "Continue with Google",
                            style: AppTheme.textLabel(context).copyWith(
                              fontFamily: AppFontFamily.poppinsSemiBold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Register Link
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTheme.textLabel(context),
                children: [
                  const TextSpan(text: 'Don’t have an account? '),
                  TextSpan(
                    text: 'Register',
                    style: AppTheme.textLink(context).copyWith(fontSize: 13),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (_isLoading || _isGoogleLoading) return;
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const SignupScreen(),
                            transitionsBuilder: (_, a, __, c) =>
                                FadeTransition(opacity: a, child: c),
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  /// Handles standard email/username + password login
  Future<void> _submitLoginForm() async {
    FocusScope.of(context).unfocus();

    if (!_validateCurrentForm()) {
      AppSnackBar.show(
        context,
        message: 'Please fill all required fields correctly',
        type: AppSnackBarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final input = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 1. Resolve email if username was provided
      String? loginEmail = input;
      if (!input.contains('@')) {
        loginEmail = await _resolveEmail(input);
        if (loginEmail == null) {
          if (!mounted) return;
          AppSnackBar.show(
            context,
            message: 'No account found with username "$input".',
            type: AppSnackBarType.error,
          );
          return;
        }
      }

      // 2. Firebase Auth Sign-In
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: loginEmail, password: password);

      final User? user = userCredential.user;
      if (user == null) {
        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: 'Authentication failed. Please try again.',
          type: AppSnackBarType.error,
        );
        return;
      }

      // 3. Fetch User Document from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('Users')
          .doc(user.uid)
          .get();

      Map<String, dynamic> userData;

      if (!userDoc.exists || userDoc.data() == null) {
        debugPrint(
          "User doc missing in Firestore. Creating default profile...",
        );
        userData = {
          'name': user.displayName ?? input.split('@').first,
          'email': user.email ?? loginEmail,
          'contact': user.phoneNumber ?? '',
          'address': '',
          'role': 'user',
          'status': true,
          'profile_image_url': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('Users').doc(user.uid).set(userData);
      } else {
        userData = userDoc.data() as Map<String, dynamic>;
      }

      // 4. Check if account is active
      final bool isActive = userData['status'] ?? true;
      if (!isActive) {
        await _auth.signOut();
        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: 'This account has been disabled by the administrator.',
          type: AppSnackBarType.error,
        );
        return;
      }

      // 5. Save local session
      await SessionManager.saveUserSession(
        user.uid,
        userData,
        _rememberMe,
        password,
      );

      // 6. Update Riverpod User State
      await ref.read(userProvider.notifier).fetchUser();

      // 7. Success & Navigate
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Welcome back, ${userData['name'] ?? 'User'}!',
        type: AppSnackBarType.success,
      );

      _navigateToDashboard();
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: _getErrorMessage(e),
        type: AppSnackBarType.error,
      );
    } catch (e, stack) {
      debugPrint("Login Error: $e\n$stack");
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Login failed: ${e.toString()}',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handles Google Sign-In flow across Web and Mobile
  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleLoading = true);
    debugPrint("Initializing Google Sign-In with client ID: $_currentGoogleClientId");

    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web: Use Firebase Auth Popup (standard and most reliable for web)
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({
          'prompt': 'select_account',
          'client_id': _webClientId,
        });
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile: Use Native Google Sign-In
        await _googleSignIn.signOut(); // Ensure fresh account picker
        await _googleSignIn.initialize(
          serverClientId: _webClientId,
        );
        final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      final User? user = userCredential.user;
      if (user == null) {
        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: 'Google sign-in failed. Please try again.',
          type: AppSnackBarType.error,
        );
        return;
      }

      // Query / Create user document in Firestore
      final DocumentReference userRef =
          _firestore.collection('Users').doc(user.uid);
      DocumentSnapshot userDoc = await userRef.get();

      Map<String, dynamic> userData;

      if (!userDoc.exists || userDoc.data() == null) {
        debugPrint("Creating new Google user profile in Firestore for uid: ${user.uid}");
        final String displayName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (user.email != null && user.email!.contains('@')
                ? user.email!.split('@').first
                : 'Google User');

        userData = {
          'uid': user.uid,
          'name': displayName,
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'contact': user.phoneNumber ?? '',
          'address': '',
          'role': 'user',
          'status': true,
          'profile_image_url': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        };
        await userRef.set(userData, SetOptions(merge: true));
      } else {
        userData = userDoc.data() as Map<String, dynamic>;
      }

      // Check if account is active
      final bool isActive = userData['status'] ?? true;
      if (!isActive) {
        await _auth.signOut();
        if (!kIsWeb) {
          await _googleSignIn.signOut();
        }
        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: 'This account has been disabled by the administrator.',
          type: AppSnackBarType.error,
        );
        return;
      }

      // Save local session
      await SessionManager.saveUserSession(
        user.uid,
        userData,
        true, // Google sign in defaults to remembered session
        '',
      );

      // Update Riverpod User State
      await ref.read(userProvider.notifier).fetchUser();

      // Success & Navigate
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Signed in as ${userData['name'] ?? 'User'}!',
        type: AppSnackBarType.success,
      );

      _navigateToDashboard();
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "Google Sign-In FirebaseAuthException: ${e.code} - ${e.message}",
      );
      if (!mounted) return;
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return; // Suppress popup cancel
      }
      AppSnackBar.show(
        context,
        message: _getErrorMessage(e),
        type: AppSnackBarType.error,
      );
    } catch (e, stack) {
      debugPrint("Google Sign-In Error: $e\n$stack");
      if (!mounted) return;
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('canceled') ||
          errorStr.contains('cancelled') ||
          errorStr.contains('interrupted') ||
          errorStr.contains('sign_in_canceled') ||
          errorStr.contains('popup_closed_by_user') ||
          errorStr.contains('popup-closed-by-user') ||
          errorStr.contains('user cancelled')) {
        return;
      }
      AppSnackBar.show(
        context,
        message: 'Google Sign-In failed: ${e.toString()}',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email/username or password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again in a few minutes.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'channel-error':
        return 'Please fill in all required credentials.';
      case 'popup-blocked':
        return 'Popup was blocked by your browser. Please allow popups for this site.';
      case 'popup-closed-by-user':
        return 'Sign in was cancelled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      default:
        return e.message ?? 'Sign in failed. Please try again.';
    }
  }
}

/// Custom Vector Google "G" Logo Widget
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w / 2;
    final double strokeWidth = w * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: r - strokeWidth / 2,
    );

    // Blue arc (bottom right to right top)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.785, 1.57, false, paint);

    // Green arc (bottom right to bottom left)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.785, 1.57, false, paint);

    // Yellow arc (bottom left to top left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.356, 1.57, false, paint);

    // Red arc (top left to top right)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.927, 1.57, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTWH(
      cx - strokeWidth * 0.2,
      cy - strokeWidth / 2,
      r * 0.95,
      strokeWidth,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
