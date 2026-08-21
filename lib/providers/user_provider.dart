import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>(
  (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    fetchUser();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> fetchUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // 1. Instant Cache-First Read (0ms latency)
    try {
      final cacheDoc = await _firestore
          .collection('Users')
          .doc(uid)
          .get(const GetOptions(source: Source.cache));
      final cacheData = cacheDoc.data();
      if (cacheData != null && mounted) {
        state = UserModel.fromMap(cacheData, uid);
      }
    } catch (_) {}

    // 2. Server Sync in Background
    try {
      final doc = await _firestore.collection('Users').doc(uid).get();
      final data = doc.data();
      if (data != null && mounted) {
        state = UserModel.fromMap(data, uid);
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }
  }

  void clearUser() {
    state = null;
  }

  Future<void> updateUser(Map<String, dynamic> updates) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('Users').doc(uid).update(updates);
      // Update local state after saving
      state = state?.copyWith(
        name: updates['name'],
        email: updates['email'],
        phone: updates['phone'],
        address: updates['address'],
        profileImage: updates['profile_image_url'],
      );
    } catch (e) {
      debugPrint("Error updating user: $e");
    }
  }
}