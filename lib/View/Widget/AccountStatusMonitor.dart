// View/Widget/AccountStatusMonitor.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss122/View/Profile/LogOutAccount/AccountList/Login-singup/Login.dart';


class AccountStatusMonitor {
  static final AccountStatusMonitor _instance = AccountStatusMonitor._();
  factory AccountStatusMonitor() => _instance;
  AccountStatusMonitor._();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _fireSub;
  Timer? _reloadTimer;

  void start() {
    _startFirestoreListener();
    _startAuthReloadChecks();
  }

  void stop() {
    _fireSub?.cancel();
    _fireSub = null;
    _reloadTimer?.cancel();
    _reloadTimer = null;
  }

  //––– Firestore listener (optional إذا كنت تستخدم حقل disabled في المستند)
  void _startFirestoreListener() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _fireSub?.cancel();
    _fireSub = FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .snapshots(includeMetadataChanges: true)
        .listen((snap) {
      final data = snap.data();
      if (data != null && data['disabled'] == true) {
        _handleDisabled();
      }
    }, onError: (e) {
      debugPrint('▶️ Firestore monitor error: $e');
    });
  }

  void _startAuthReloadChecks() {
    _reloadTimer?.cancel();
    _checkAuthDisabled();
    _reloadTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAuthDisabled();
    });
  }

  Future<void> _checkAuthDisabled() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-disabled') {
        _handleDisabled();
      } else {
        debugPrint('▶️ reload error (${e.code}): ${e.message}');
      }
    } catch (e) {
      debugPrint('▶️ unexpected reload error: $e');
    }
  }

  void _handleDisabled() {
    stop();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                'Session Expired'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your account has been disabled.'.tr,
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Get.offAll(Login());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    'OK'.tr,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

  }
}
