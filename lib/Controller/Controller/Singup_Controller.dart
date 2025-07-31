import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Singup_Controller extends GetxController {
  bool notvisible = false;
  bool notvisible2 = false;
  bool notVisiblePassword = false;
  bool notVisiblePassword2 = false;
  Icon passwordIcon = const Icon(Icons.visibility);
  Icon passwordIcon2 = const Icon(Icons.visibility);

  void passwordVisibility() {
    if (notVisiblePassword) {
      passwordIcon = const Icon(Icons.visibility_off);
    } else {
      passwordIcon = const Icon(Icons.visibility);
    }
  }

  void passwordVisibility2() {
    if (notVisiblePassword2) {
      passwordIcon2 = const Icon(Icons.visibility_off);
    } else {
      passwordIcon2 = const Icon(Icons.visibility);
    }
  }

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

  String? validatePassword(
      String? value, String? confirmPassword, bool isConfirmPassword) {
    if (value == null || value.isEmpty) {
      return "Password cannot be empty".tr;
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long".tr;
    }
    if (isConfirmPassword &&
        confirmPassword != null &&
        value != confirmPassword) {
      return "Passwords do not match".tr;
    }
    return null;
  }

  String? PhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your phone number".tr;
    }
    return null;
  }

  String? YourName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Name".tr;
    }
    return null;
  }
  void Confirm_Password(){
    notvisible2 = !notvisible2;
    notVisiblePassword2 =
    !notVisiblePassword2;
    passwordVisibility2();
  }
  void Password2(){
    notvisible = !notvisible;
    notVisiblePassword =
    !notVisiblePassword;
    passwordVisibility();
  }
}
