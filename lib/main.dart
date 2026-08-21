import 'dart:ui' show PlatformDispatcher, PointerDeviceKind;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/firebase_options.dart';
import '/screens/splash_screen.dart';
import '/screens/auth/login_screen.dart';
import '/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Crash Resilience: Catch and handle unhandled framework and async errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('App Global Error: ${details.exception}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Async Unhandled Error: $error');
    return true;
  };

  // 2. System UI orientation configuration
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. Parallelized critical startup tasks
  await Future.wait([
    ThemeController.loadTheme(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  // 4. Enterprise-Scale Firestore offline persistence & unlimited caching
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firestore settings note: $e');
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // bool _isDesktopOrWeb(BuildContext context) {
  //   if (kIsWeb) return true;
  //   final platform = defaultTargetPlatform;
  //   return platform == TargetPlatform.windows ||
  //       platform == TargetPlatform.macOS ||
  //       platform == TargetPlatform.linux;
  // }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (_, themeMode, __) {
        return SafeArea(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: MyTheme.lightTheme,
            darkTheme: MyTheme.darkTheme,
            themeMode: themeMode, // 👈 controlled by ThemeController
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            builder: (context, child) {
              // final isDesktop =
              //     _isDesktopOrWeb(context) ||
              //     MediaQuery.of(context).size.width >= 900;

              // if (isDesktop) {
              //   // ✅ Desktop/Web — full width, no text scale constraint
              //   return MediaQuery(
              //     data: MediaQuery.of(
              //       context,
              //     ).copyWith(textScaler: const TextScaler.linear(1.0)),
              //     child: ColoredBox(
              //       color: Theme.of(context).scaffoldBackgroundColor,
              //       child: child!,
              //     ),
              //   );
              // }

              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(0.8), // 🔥 fixed scale
                ),
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: LayoutBuilder(
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
                  ),
                ),
              );
            },
            home: SplashScreen(
              nextScreen: const LoginScreen(),
              duration: const Duration(seconds: 3),
            ),
          ),
        );
      },
    );
  }
}
