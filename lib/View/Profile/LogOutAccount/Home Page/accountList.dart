// ignore: file_names
// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, camel_case_types, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:url_launcher/url_launcher.dart';

import '../AccountList/Language.dart';
import '../AccountList/Login-singup/Login.dart';
import 'accountimage.dart';



class accountList extends StatefulWidget {
  @override
  const accountList({super.key});

  @override
  State<accountList> createState() => accountList1();
}


class accountList1 extends State<accountList> {
  late bool lag = false;

  final List<Map<String, dynamic>> data = [
    {
      "Text": "تسجيل الدخول / اشتراك".tr,
      "Text1": "Log in / Sign up".tr,
      "icon": Icons.fingerprint,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "اللغة".tr,
      "Text1": "Language".tr,
      "icon": Icons.translate,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "حقوق الملكية".tr,
      "Text1": "Property rights".tr,
      "icon": Icons.copyright,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "شروط الاستخدام".tr,
      "Text1": "Terms of use".tr,
      "icon": Icons.assignment,
      "icon2": Icons.arrow_forward_ios,
    },
    {
      "Text": "سياسة الخصوصية".tr,
      "Text1": "Privacy policy".tr,
      "icon": Icons.security,

      "icon2": Icons.arrow_forward_ios,
    },
  ];
  Future<void> _launchURL(String url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  late List<Function> data1 = [];

  @override
  void initState() {
    super.initState();
    initializeData1Functions();
  }



  void initializeData1Functions() {
    data1 = [
          () => Get.to(const Login(), transition: Transition.fadeIn),
          () => Get.to(const Language(), transition: Transition.fadeIn),
          () => _launchURL("https://faithful-canna-p08q8r.mystrikingly.com/"),
          () => _launchURL("https://faithful-canna-p08q8r.mystrikingly.com/"),
          () => _launchURL("https://faithful-canna-p08q8r.mystrikingly.com/"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, i) {
        return Column(
          children: [
            if (i == 0) const accountImage(),
            Container(
              height: 60,
              decoration:  BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (data1 != null && i < data1.length) {
                    data1[i]();
                  }
                },
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
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
                          data[i]['icon'],
                          size: 30,
                          color: Color(0xFF1A4C9C),
                        ),
                        Container(
                          width: 10,
                        ),
                        Text(Get.locale?.languageCode == 'ar'
                            ? data[i]['Text'] ?? 'قيمة افتراضية':
                        data[i]['Text1'] ?? 'قيمة افتراضية',
                          style:  TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      data[i]['icon2'],
                      size: 20,
                      color: Color(0xFF1A4C9C),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
