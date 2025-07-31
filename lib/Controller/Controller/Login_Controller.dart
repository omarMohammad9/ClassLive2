import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Login_Controller extends GetxController {
  bool notVisiblePassword = false;
  Icon passwordIcon = const Icon(Icons.visibility);
  bool notvisible = false;
  bool emailFormVisibility = true;

  String? EmailID(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email".tr;
    }

    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email'.tr;
    }
    return null;
  }
  String? PhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your phone number".tr;
    }
    return null;
  }

  void passwordVisibility() {
    if (notVisiblePassword) {
      passwordIcon = const Icon(Icons.visibility_off);
    } else {
      passwordIcon = const Icon(Icons.visibility);
    }
  }
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password cannot be empty".tr;
    }

    return null;
  }
}
