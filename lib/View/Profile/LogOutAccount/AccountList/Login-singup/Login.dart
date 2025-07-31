import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../api/firebase_api.dart';
import 'reset_password.dart';
import 'singup.dart';
import '../../../../Home/Home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginPage();
}

class _LoginPage extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  // نستخدم نفس الأسماء الأصلية للحفاظ على التصميم دون تغيير
  final id = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();

  // سنستغني عن Login_Controller الخارجي ونطبق منطق بسيط هنا
  bool emailFormVisibility = true;
  bool notvisible = true; // لإخفاء/إظهار كلمة المرور
  bool _loading = false;

  @override
  void dispose() {
    id.dispose();
    password.dispose();
    phone.dispose();
    super.dispose();
  }

  // ===== Validators بديلة مبسطة =====
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter email'.tr;
    final re = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!re.hasMatch(v.trim())) return 'Invalid email format'.tr;
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter password'.tr;
    if (v.length < 6) return 'Minimum 6 characters'.tr;
    return null;
  }

  String? _validatePhone(String? v) {
    if (!emailFormVisibility) {
      if (v == null || v.isEmpty) return 'Enter phone number'.tr;
      if (!RegExp(r'^\d{10}$').hasMatch(v)) return 'Enter 10 digits'.tr;
    }
    return null;
  }

  // ===== Firebase Email Login =====
  Future<void> _loginWithEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: id.text.trim(),
        password: password.text,
      );
      final uid = FirebaseAuth.instance.currentUser!.uid;
      try {
        await FirebaseFirestore.instance
            .collection('User')       // ← هنا تستخدم FirebaseFirestore
            .doc(uid)
            .update({'fcmToken':FirebaseApi.fCMToken });
      } catch (e) {
        print('Error disabling user in Firestore: $e');
      }

      if (cred.user != null) {
        Get.snackbar(
          'Success'.tr,
          'Logged in successfully'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAll(() => const Home());
      } else {
        Get.snackbar(
          'Error'.tr,
          'Login failed'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'No user found for that email.'.tr;
          break;
        case 'wrong-password':
          msg = 'Wrong password provided.'.tr;
          break;
        case 'invalid-email':
          msg = 'Invalid email.'.tr;
          break;
        case 'user-disabled':
          msg = 'User disabled.'.tr;
          break;
        default:
          msg = 'Authentication error'.tr;
      }
      Get.snackbar(
        'Error'.tr,
        msg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Something went wrong'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _loginWithPhoneComingSoon() {
    Get.snackbar(
      'Coming soon'.tr,
      'the login option via phone number will be activated'.tr,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.grey,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(

      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              "images/19366.jpg",
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    height: 250,
                    child: Image.asset('images/login-removebg-preview.png'),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Login'.tr,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ==== Form ====
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (emailFormVisibility) ...[
                              TextFormField(
                                controller: id,
                                validator: _validateEmail,
                                decoration: InputDecoration(
                                  icon: const Icon(
                                    Icons.alternate_email_outlined,
                                    color: Colors.grey,
                                  ),
                                  labelText: 'Email ID'.tr,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emailFormVisibility = false;
                                      });
                                    },
                                    icon: const Icon(
                                        Icons.phone_android_rounded),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF1A4C9C)),
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: password,
                                obscureText: notvisible,
                                validator: _validatePassword,
                                decoration: InputDecoration(
                                  icon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.grey,
                                  ),
                                  labelText: 'Password'.tr,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        notvisible = !notvisible;
                                      });
                                    },
                                    icon: Icon(
                                      notvisible
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                    ),
                                    
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF1A4C9C)),
                                  ),
                                ),
                              ),
                            ] else ...[
                              TextFormField(
                                controller: phone,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                validator: _validatePhone,
                                decoration: InputDecoration(
                                  icon: const Icon(
                                    Icons.phone_android_rounded,
                                    color: Colors.grey,
                                  ),
                                  labelText: 'Phone Number'.tr,
                                  counterText: "",
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emailFormVisibility = true;
                                      });
                                    },
                                    icon: const Icon(
                                        Icons.alternate_email_rounded),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 13),

                      // Forgot Password
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              child: Text(
                                'Forgot Password?'.tr,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A4C9C),
                                ),
                              ),
                              onTap: () {
                                Get.to(() =>  RESETpasswordPage());
                              },
                            ),
                          ],
                        ),
                      ),

                      // Login Button
                      ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () {
                          if (emailFormVisibility) {
                            _loginWithEmail();
                          } else {
                            if (_formKey.currentState?.validate() ??
                                false) {
                              _loginWithPhoneComingSoon();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A4C9C),
                          minimumSize: const Size.fromHeight(45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : Text(
                            "Login".tr,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Divider + OR (كما هو)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Divider(thickness: 1, color: Colors.grey),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF1A4C9C),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "OR".tr,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Login with Google (مستقبلاً)
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Google Sign-In لاحقاً
                        },
                        icon: Image.asset(
                          'images/google_logo.png',
                          width: 20,
                          height: 20,
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(45),
                          backgroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        label: Center(
                          child: Text(
                            "Login with Google".tr,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New to the App?".tr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            child: Text(
                              "Register".tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A4C9C),
                              ),
                            ),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  SignUpPage(),
                                ),
                              );
                            },
                          ),

                        ],
                      ),
                      const SizedBox(height: 100),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
