import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'View/FirstPage/firstpage.dart';
import 'View/Widget/AccountStatusMonitor.dart';
import 'api/firebase_api.dart';
import 'View/Profile/LogInAccount/AccountList/Notifications.dart';
import 'locale/locale.dart';
import 'locale/localeController.dart';
import 'package:screen_protector/screen_protector.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('تم استلام إشعار في الخلفية: ${message.notification?.title}');
  await _saveMessageDirectlyToFirestore(message);
}

Future<void> _saveMessageDirectlyToFirestore(RemoteMessage message) async {
  try {
    String? lastUserId = await _getLastLoggedInUserId();

    if (lastUserId == null || lastUserId.isEmpty) {
      print('لا يوجد مستخدم مسجل دخول لحفظ الإشعار');
      return;
    }

    String messageId = message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();

    // التحقق من عدم وجود الرسالة مسبقًا
    QuerySnapshot existingDocs = await FirebaseFirestore.instance
        .collection('User')
        .doc(lastUserId)
        .collection('notifications')
        .where('messageId', isEqualTo: messageId)
        .limit(1)
        .get();

    if (existingDocs.docs.isNotEmpty) {
      print('الإشعار موجود مسبقًا في Firestore');
      return;
    }

    final data = {
      'title': message.data['title'] ?? message.notification?.title ?? 'لا يوجد عنوان',
      'body': message.data['body'] ?? message.notification?.body ?? 'لا يوجد محتوى',
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'data': message.data,
      'messageId': messageId,
      'from': message.from ?? '',
      'category': message.category ?? '',
    };

    await FirebaseFirestore.instance
        .collection('User')
        .doc(lastUserId)
        .collection('notifications')
        .add(data);

    print('تم حفظ الإشعار مباشرة في Firestore: ${data['title']}');

  } catch (e) {
    print('خطأ في حفظ الإشعار مباشرة: $e');
  }
}

/// الحصول على معرف آخر مستخدم مسجل دخول
Future<String?> _getLastLoggedInUserId() async {
  try {
    // محاولة الحصول على المستخدم الحالي
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    }

    // إذا لم يكن هناك مستخدم حالي، جرب استخدام SharedPreferences
    // (ستحتاج إلى حفظ UID عند تسجيل الدخول)
    return null;
  } catch (e) {
    print('خطأ في الحصول على معرف المستخدم: $e');
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ScreenProtector.preventScreenshotOn();
  await initializeDateFormatting('ar');

  // سجل معالج الخلفية - يحفظ الإشعارات مباشرة عندما يكون التطبيق مغلق
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Get.put(MyLocaleController());
  Get.put(AccountStatusMonitor(), permanent: true);

  // مراقبة حالة تسجيل الدخول
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    final mon = Get.find<AccountStatusMonitor>();
    if (user != null) {
      mon.start();
      print('تم تسجيل دخول المستخدم: ${user.uid}');
    } else {
      mon.stop();
      print('تم تسجيل خروج المستخدم');
    }
  });

  // احصل على الـ FCM token
  await FirebaseApi().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final localeCtrl = Get.find<MyLocaleController>();

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _startGlobalMessageListener();
    _handleInitialMessage();
  }

  Future<void> _requestNotificationPermission() async {
    await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
  }

  /// يخزّن كل رسالة واردة مباشرة في Firestore
  void _startGlobalMessageListener() {
    // عند استلام الرسالة أثناء استخدام التطبيق (foreground)
    FirebaseMessaging.onMessage.listen((msg) async {
      print('تم استلام إشعار أثناء استخدام التطبيق: ${msg.notification?.title}');
      await _saveMessageToFirestore(msg);
    });

    // عند فتح التطبيق من خلال النقر على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((msg) async {
      print('تم فتح التطبيق من خلال النقر على الإشعار: ${msg.notification?.title}');
      await _saveMessageToFirestore(msg);
      await Future.delayed(const Duration(milliseconds: 300));
      Get.to(() => const NotificationsPage());
    });
  }

  /// التعامل مع الإشعار الذي فتح به التطبيق عندما كان مغلقًا تمامًا
  void _handleInitialMessage() async {
    try {
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        print('تم فتح التطبيق من خلال إشعار أولي: ${initialMessage.notification?.title}');
        await _saveMessageToFirestore(initialMessage);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.to(() => const NotificationsPage());
      }
    } catch (e) {
      print('خطأ في معالجة الإشعار الأولي: $e');
    }
  }

  /// حفظ الإشعار مباشرة في Firestore
  Future<void> _saveMessageToFirestore(RemoteMessage msg) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('المستخدم غير مسجل دخول، لا يمكن حفظ الإشعار');
      return;
    }

    try {
      String messageId = msg.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();

      // التحقق من عدم وجود الرسالة مسبقًا
      QuerySnapshot existingDocs = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .collection('notifications')
          .where('messageId', isEqualTo: messageId)
          .limit(1)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        print('الإشعار موجود مسبقًا في Firestore');
        return;
      }

      final data = {
        'title': msg.data['title'] ?? msg.notification?.title ?? 'لا يوجد عنوان',
        'body': msg.data['body'] ?? msg.notification?.body ?? 'لا يوجد محتوى',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'data': msg.data,
        'messageId': messageId,
        'from': msg.from ?? '',
        'category': msg.category ?? '',
      };

      await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .collection('notifications')
          .add(data);

      print('تم حفظ الإشعار في Firestore: ${data['title']}');

    } catch (e) {
      print('خطأ في حفظ الإشعار في Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: localeCtrl.intiailang,
      translations: MyLocale(),
      debugShowCheckedModeBanner: false,
      home: const firstpage(),
    );
  }
}