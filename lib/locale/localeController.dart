import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLocaleController extends GetxController {
  SharedPreferences? sharepref;

  Locale? intiailang;

  @override
  void onInit() {
    super.onInit();
    _loadSharedPreferences();
  }

  void _loadSharedPreferences() async {
    sharepref = await SharedPreferences.getInstance();
    String? lang = sharepref?.getString("lang");
    if (lang != null) {
      intiailang = Locale(lang);
      Get.updateLocale(intiailang!);
    }
  }

  void changelang(String codelang) async {
    Locale locale = Locale(codelang);
    sharepref = await SharedPreferences.getInstance();
    sharepref!.setString("lang", codelang);
    Get.updateLocale(locale);
    intiailang = locale;
  }
}
