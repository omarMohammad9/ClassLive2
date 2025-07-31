import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseApi {
  final firebaseMessaging = FirebaseMessaging.instance;
  static String? fCMToken;


  Future<void> initNotifications() async {
    await firebaseMessaging.requestPermission();
    fCMToken = await firebaseMessaging.getToken();
    print('Token: $fCMToken');


    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', fCMToken ?? '');

  }
}
