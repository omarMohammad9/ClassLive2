import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // إضافة

import '../../../../../Controller/Controller/reset_password_Controller.dart';
import 'Login.dart';

class RESETpasswordPage extends StatefulWidget {
  const RESETpasswordPage({super.key});

  @override
  State<RESETpasswordPage> createState() => _RESETpasswordState();
}

class _RESETpasswordState extends State<RESETpasswordPage> {
  final reset_password_Controller controller = reset_password_Controller();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
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

  Future<void> _sendResetEmail() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email.text.trim());
      Get.snackbar(
        'Success'.tr,
        'Password reset email sent.'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );


      Future.delayed(const Duration(seconds: 2), () {
        Get.back(); // يغلق الديالوك
        Get.to(() => Login(), transition: Transition.fadeIn);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        fit:StackFit.expand ,
        children: [
          Positioned.fill(
            child: Image.asset(
              "images/19366.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(
                        height: 300,
                        child: Image.asset(
                            'images/reset_password-removebg-preview.png')),
                    Row(
                      children: [
                        Container(
                          child: Text(
                            'Forgot \nPassword?'.tr,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          child: Text(
                            "Don't worry! It happens. Please enter the \naddress associated with the account."
                                .tr,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          decoration: InputDecoration(
                              icon: const Icon(Icons.alternate_email_outlined,
                                  color: Colors.grey),
                              labelText: 'Email ID'.tr),
                          controller: email,
                          validator: EmailID,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _sendResetEmail();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A4C9C),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: Center(
                          child: Text(
                        "Reset".tr,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white),
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
