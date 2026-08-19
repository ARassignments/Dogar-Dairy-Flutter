import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../notifiers/avatar_notifier.dart';

class SessionManager {
  static const String _userIdKey = "USER_ID";
  static const String _userKey = "USER";
  static const String _userPasswordKey = "USER_PASSWORD";
  static const String _rememberMeKey = "REMEMBER_ME";
  static const String _organizationIdKey = "ORGANIZATION_ID";

  static const String _avatarKey = "USER_AVATAR";
  static const String _genderKey = "USER_GENDER";
  static const String _onboardingCompletedKey = "ONBOARDING_COMPLETED";

  /// Set onboarding completed flag
  static Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  /// Get onboarding completed flag
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Converts non-JSON-encodable objects (like Cloud Firestore Timestamp, FieldValue, DateTime, etc.) to encodable primitives.
  static dynamic _toEncodable(dynamic nonEncodable) {
    if (nonEncodable == null) return null;
    if (nonEncodable is DateTime) {
      return nonEncodable.toIso8601String();
    }
    // Handle Cloud Firestore Timestamp or any object having toDate()
    try {
      final dynamic obj = nonEncodable;
      if (obj.toDate != null) {
        final date = obj.toDate();
        if (date is DateTime) {
          return date.toIso8601String();
        }
      }
    } catch (_) {}
    try {
      final dynamic obj = nonEncodable;
      if (obj.millisecondsSinceEpoch != null) {
        return obj.millisecondsSinceEpoch;
      }
    } catch (_) {}
    return nonEncodable.toString();
  }

  /// Recursively cleans map to ensure all values are JSON serializable
  static Map<String, dynamic> _cleanMap(Map<String, dynamic> source) {
    final Map<String, dynamic> cleaned = {};
    source.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        cleaned[key] = _cleanMap(value);
      } else if (value is List) {
        cleaned[key] = value.map((item) {
          if (item is Map<String, dynamic>) return _cleanMap(item);
          if (item is String || item is num || item is bool || item == null) {
            return item;
          }
          return _toEncodable(item);
        }).toList();
      } else if (value is String || value is num || value is bool || value == null) {
        cleaned[key] = value;
      } else {
        cleaned[key] = _toEncodable(value);
      }
    });
    return cleaned;
  }

  /// Save user session
  static Future<void> saveUserSession(
    String userId,
    Map<String, dynamic> user,
    bool rememberMe,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);

    final cleanData = _cleanMap(user);
    final encodedUser = jsonEncode(
      cleanData,
      toEncodable: (item) => _toEncodable(item),
    );
    await prefs.setString(_userKey, encodedUser);
    await prefs.setBool(_rememberMeKey, rememberMe);
    await prefs.setString(_userPasswordKey, password);
  }

  /// Save avatar + gender (independent of API session)
  static Future<void> saveAvatarAndGender(String gender, String avatarPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarKey, avatarPath);
    await prefs.setString(_genderKey, gender);
    avatarNotifier.updateAvatar(avatarPath);
  }

  /// Get avatar + gender
  static Future<Map<String, String?>> getAvatarAndGender() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "gender": prefs.getString(_genderKey),
      "avatar": prefs.getString(_avatarKey),
    };
  }

  /// Get User Id
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get user object
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  /// Get remember me flag
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

   /// Get user password
  static Future<String?> getUserPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPasswordKey);
  }

  /// Get organization id
  static Future<int?> getOrganizationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_organizationIdKey);
  }

  /// Clear session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userKey);
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_userPasswordKey);
    await prefs.remove(_organizationIdKey);
    await prefs.remove(_avatarKey);
    await prefs.remove(_genderKey);
  }
}
