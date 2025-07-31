import 'package:get/get.dart';
class reset_password_Controller extends GetxController{
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
}