// ignore_for_file: deprecated_member_use, use_build_context_synchronously, empty_catches, non_constant_identifier_names, camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../BottomNavigation/bottomNavigation.dart';
import '../../Home/Home.dart';
import '../LogOutAccount/AccountList/Language.dart';
import '../LogOutAccount/Home Page/accountimage.dart';
import 'AccountList/Acoount Details.dart';
import 'AccountList/ChangePasswordPage.dart';
import 'AccountList/DeleteAccountPage.dart';
import 'AccountList/Notifications.dart';

class personal extends StatefulWidget {
  const personal({super.key});

  @override
  State<personal> createState() => personal1();
}

class personal1 extends State<personal> {
  List<Map<String, dynamic>> data2 = [
    {
      "Text": "الاشعارات",
      "Text1": "Notifications",
      "iconHome": Icons.notifications,
      "icon2": Icons.arrow_forward_ios,
    },
  ];

  List<Map<String, dynamic>> data = [
    {
      "Text": "تفاصيل الحساب",
      "Text1": "Account Details",
      "iconHome": Icons.account_circle_outlined,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "تغير كلمة السر",
      "Text1": "Change Password",
      "iconHome": Icons.lock,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "الاشعارات",
      "Text1": "Notifications",
      "iconHome": Icons.notifications,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "اللغة",
      "Text1": "Language",
      "iconHome": Icons.language,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "شروط الاستخدام",
      "Text1": "terms of use",
      "iconHome": Icons.text_snippet_outlined,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "سياسة الخصوصية",
      "Text1": "privacy policy",
      "iconHome": Icons.privacy_tip_outlined,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "حقوق الملكية",
      "Text1": "Property rights",
      "iconHome": Icons.settings_backup_restore,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "اعدادات الحساب",
      "Text1": "account settings",
      "iconHome": Icons.settings,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "خروج",
      "Text1": "Logout",
      "iconHome": Icons.exit_to_app_sharp,
      "icon2": Icons.arrow_forward_ios,
    },
  ];

  late List<Function> data1;

  @override
  void initState() {
    super.initState();
    data1 = [
          () => Get.to(AcoountDetails()),
          () => Get.to(ChangePasswordPage()),
          () => Get.to(NotificationsPage()),
          () => Get.to(Language()),
          () => _launchURL("https://faithful-canna-p08q8r.mystrikingly.com/"),
          () => _launchURL("https://faithful-canna-p08q8r.mystrikingly.com/"),
          () => _launchURL("https://faithful-canna-p08q8r.mystrikingly.com/"),
          () => Get.to(DeleteAccountPage()),
          () => signOut(),
    ];
  }

  Future<void> _launchURL(String url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => Home());
      Get.snackbar(
        'Success'.tr,
        'Logout Success'.tr,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 10,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        shouldIconPulse: true,
        barBlur: 20,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Logout Failed'.tr + ' ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 7, right: 7, bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BottomNavigation(selectedIndex: 4),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A4C9C),
        title: Text("MyProfile".tr,
            style: const TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .doc(user?.uid)
            .collection('notifications')
            .where('read', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          final unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              return Column(
                children: [
                  if (i == 0) accountImage(),
                  Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.brown)),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (i < data1.length) {
                          data1[i]();
                        }
                      },
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0),
                        backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                        overlayColor:
                        MaterialStateProperty.all(Colors.transparent),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        textDirection: Get.locale?.languageCode == 'ar'
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: [
                          Row(
                            textDirection: Get.locale?.languageCode == 'ar'
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            children: [
                              Icon(
                                data[i]['iconHome'],
                                size: 30,
                                color: const Color(0xFF1A4C9C),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  Text(
                                    Get.locale?.languageCode == 'ar'
                                        ? data[i]['Text'] ?? 'قيمة افتراضية'
                                        : data[i]['Text1'] ?? 'Default',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  if (data[i]['Text'] == 'الاشعارات' &&
                                      unreadCount > 0)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.yellow[700],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      width: 20,
                                      height: 20,
                                      child: Center(
                                        child: Text(
                                          unreadCount.toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          Icon(
                            data[i]['icon2'],
                            size: 20,
                            color: const Color(0xFF1A4C9C),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
