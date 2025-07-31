// View/Widget/AccountStatusMonitor.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss122/View/Profile/LogOutAccount/AccountList/Login-singup/Login.dart';

import '../Home/Home.dart';
import '../Profile/LogOutAccount/Home Page/accountHome.dart';
import '../Profile/LogOutAccount/Home Page/accountList.dart';

class AccountStatusMonitor {
  static final AccountStatusMonitor _instance = AccountStatusMonitor._();
  factory AccountStatusMonitor() => _instance;
  AccountStatusMonitor._();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _fireSub;
  Timer? _reloadTimer;

  /// ابدأ المراقبة كلياً
  void start() {
    _startFirestoreListener();
    _startAuthReloadChecks();
  }

  /// أوقف كل المراقبات
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

  //––– Authentication reload checker
  void _startAuthReloadChecks() {
    _reloadTimer?.cancel();
    // تأكّد فوراً
    _checkAuthDisabled();
    // ثم دوريّاً كل دقيقة (يمكنك تعديل المديّة)
    _reloadTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAuthDisabled();
    });
  }

  Future<void> _checkAuthDisabled() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await user.reload();
      // إذا لم يرمي استثناء => الحساب لا يزال مفعل
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

  //––– معاملة التعطيل (عرض حوار + تسجيل خروج)
  void _handleDisabled() {
    stop(); // أوقف كل المراقبات عشان ما يتكرّر
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
                    Get.offAll(Home());
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
