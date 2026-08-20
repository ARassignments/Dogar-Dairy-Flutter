import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import '/components/appsnackbar.dart';

class NotificationService {
  static const String _keyMaster = "NOTIF_MASTER_ENABLED";
  static const String _keyDelivery = "NOTIF_DELIVERY_ALERTS";
  static const String _keyKhata = "NOTIF_KHATA_ALERTS";
  static const String _keyOffers = "NOTIF_OFFERS_ALERTS";
  static const String _keyOrder = "NOTIF_ORDER_ALERTS";
  static const String _keySound = "NOTIF_SOUND_ENABLED";

  // Cache settings
  static bool masterEnabled = true;
  static bool deliveryAlerts = true;
  static bool khataAlerts = true;
  static bool offersAlerts = false;
  static bool orderAlerts = true;
  static bool soundEnabled = true;

  /// Initialize and load stored settings
  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    masterEnabled = prefs.getBool(_keyMaster) ?? true;
    deliveryAlerts = prefs.getBool(_keyDelivery) ?? true;
    khataAlerts = prefs.getBool(_keyKhata) ?? true;
    offersAlerts = prefs.getBool(_keyOffers) ?? false;
    orderAlerts = prefs.getBool(_keyOrder) ?? true;
    soundEnabled = prefs.getBool(_keySound) ?? true;
  }

  /// Update Master Switch (All Platforms)
  static Future<void> setMasterEnabled(bool value) async {
    masterEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMaster, value);
  }

  /// Update individual preference
  static Future<void> updatePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    switch (key) {
      case _keyDelivery:
        deliveryAlerts = value;
        break;
      case _keyKhata:
        khataAlerts = value;
        break;
      case _keyOffers:
        offersAlerts = value;
        break;
      case _keyOrder:
        orderAlerts = value;
        break;
      case _keySound:
        soundEnabled = value;
        break;
    }
  }

  /// Request notification permission across supported platforms
  static Future<bool> requestPermission() async {
    if (kIsWeb) {
      try {
        if (html.Notification.supported) {
          final permission = await html.Notification.requestPermission();
          return permission == 'granted';
        }
      } catch (e) {
        debugPrint("Web notification permission error: $e");
      }
      return true;
    }

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        final status = await Permission.notification.request();
        return status.isGranted;
      } catch (e) {
        debugPrint("Mobile notification permission error: $e");
      }
    }

    return true;
  }

  /// Get current platform name for UI badge
  static String getPlatformName() {
    if (kIsWeb) return "Web Browser";
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return "Android";
      case TargetPlatform.iOS:
        return "iOS";
      case TargetPlatform.windows:
        return "Windows";
      case TargetPlatform.macOS:
        return "macOS";
      case TargetPlatform.linux:
        return "Linux";
      default:
        return "Cross-Platform";
    }
  }

  /// Dispatches notification to Web Browser API, in-app AwesomeSnackbar banner, and Desktop/Mobile
  static Future<void> showNotification(
    BuildContext context, {
    required String title,
    required String message,
    AppSnackBarType type = AppSnackBarType.success,
  }) async {
    if (!masterEnabled) return;

    // 1. Web Native Notification (if on Web)
    if (kIsWeb) {
      try {
        if (html.Notification.supported &&
            html.Notification.permission == 'granted') {
          html.Notification(
            title,
            body: message,
            icon: 'assets/images/favicon.jpg',
          );
        }
      } catch (e) {
        debugPrint("Web notification dispatch error: $e");
      }
    }

    // 2. In-App Rich Banner on all platforms (Android, iOS, Web, Windows)
    if (context.mounted) {
      AppSnackBar.showAwesomeSnackbar(
        context,
        title: title,
        message: message,
        type: type,
      );
    }
  }

  /// Send test notification to verify all device settings
  static Future<void> sendTestNotification(
    BuildContext context, {
    String? customTitle,
    String? customMessage,
  }) async {
    final title = customTitle ?? "Dogar Dairy Notification";
    final message =
        customMessage ??
        "Fresh buffalo milk route dispatch scheduled for 6:30 AM tomorrow!";

    await showNotification(
      context,
      title: title,
      message: message,
      type: AppSnackBarType.success,
    );
  }

  // Preference Key Getters
  static String get keyDelivery => _keyDelivery;
  static String get keyKhata => _keyKhata;
  static String get keyOffers => _keyOffers;
  static String get keyOrder => _keyOrder;
  static String get keySound => _keySound;
}
