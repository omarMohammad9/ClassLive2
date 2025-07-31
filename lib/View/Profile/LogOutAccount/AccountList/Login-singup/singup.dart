import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../../Controller/Controller/Singup_Controller.dart';
import '../../../../Home/Home.dart';
import 'Login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final Singup_Controller Singup_Controller1 = Singup_Controller();
  final _formKey = GlobalKey<FormState>();

  String? selectedGrade;

  final Map<String, String> gradesMap = {
    'Grade 5': 'Grade 5'.tr,
    'Grade 6': 'Grade 6'.tr,
    'Grade 7': 'Grade 7'.tr,
    'Grade 8': 'Grade 8'.tr,
    'Grade 9': 'Grade 9'.tr,
    'Grade 10': 'Grade 10'.tr,
    'Grade 11': 'Grade 11'.tr,
    'Grade 12': 'Grade 12'.tr,
    'University Student': 'University Student'.tr,
  };

  final id = TextEditingController();
  final password = TextEditingController();
  final password2 = TextEditingController();
  final phone = TextEditingController();
  final Name = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    id.dispose();
    password.dispose();
    password2.dispose();
    phone.dispose();
    Name.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    try {
      // 1) إنشاء الحساب في Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: id.text.trim(),
        password: password.text,
      );

      // 2) جلب FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();

      // 3) استخدام الـ full name كـ document ID
      final docId = cred.user!.uid;

      // 4) تخزين البيانات في Firestore
      await FirebaseFirestore.instance.collection('User').doc(docId).set({
        'uid': cred.user!.uid,
        'fullName': Name.text.trim(),
        'email': id.text.trim(),
        'Grade': selectedGrade,
        'role': 'user',
        'phone': phone.text.trim(),
        'fcmToken': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
      });


      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userDocId', docId);
      await prefs.setString('fullName', docId);
      await prefs.setString('email', id.text.trim());

      Get.snackbar(
        'Success'.tr,
        'Registered successfully'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAll(() => const Home());
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'This email is already in use.'.tr;
          break;
        case 'invalid-email':
          msg = 'Invalid email address.'.tr;
          break;
        case 'weak-password':
          msg = 'The password is too weak.'.tr;
          break;
        default:
          msg = 'Registration failed: ${e.message}'.tr;
      }
      Get.snackbar('Error'.tr, msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset("images/19366.jpg", fit: BoxFit.cover),
          ),
          Container(
            height: size.height,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  SizedBox(
                    height: size.height / 4,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.asset('images/signup-removebg-preview.png'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text('Register'.tr,
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins')),
                        ),
                        const SizedBox(height: 10),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.account_circle,
                                      color: Colors.grey),
                                  labelText: 'Your Name'.tr,
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF1A4C9C)),
                                  ),
                                ),
                                controller: Name,
                                validator: Singup_Controller1.YourName,
                              ),
                              TextFormField(
                                controller: phone,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.phone_android_rounded,
                                      color: Colors.grey),
                                  labelText: 'Phone Number'.tr,
                                  counterText: "",
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF1A4C9C)),
                                  ),
                                ),
                                validator: Singup_Controller1.PhoneNumber,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  icon: const Icon(
                                      Icons.alternate_email_outlined,
                                      color: Colors.grey),
                                  labelText: 'Email ID'.tr,
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF1A4C9C)),
                                  ),
                                ),
                                controller: id,
                                validator: Singup_Controller1.EmailID,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 3, left: 3),
                                child: Row(
                                  children: [
                                    Icon(Icons.school, color: Colors.black38),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xFF1A4C9C)),
                                          ),
                                          filled: true,
                                          fillColor: Colors.transparent,
                                        ),
                                        value: selectedGrade,
                                        hint: Text('Select Grade'.tr),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select your grade'
                                                .tr; // ✅ نص الرسالة عند عدم الاختيار
                                          }
                                          return null;
                                        },
                                        items: gradesMap.entries.map((entry) {
                                          return DropdownMenuItem<String>(
                                            value: entry.key,
                                            // القيمة الحقيقية (بالإنجليزي)
                                            child: Text(entry
                                                .value), // المعروض للمستخدم (مترجم)
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGrade = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextFormField(
                                obscureText: Singup_Controller1.notvisible,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.lock_outline_rounded,
                                      color: Colors.grey),
                                  labelText: 'Password'.tr,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        Singup_Controller1.Password2();
                                      });
                                    },
                                    icon: Singup_Controller1.passwordIcon,
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF1A4C9C)),
                                  ),
                                ),
                                controller: password,
                                validator: (v) =>
                                    Singup_Controller1.validatePassword(
                                        v, password2.text, false),
                              ),
                              TextFormField(
                                obscureText: Singup_Controller1.notvisible2,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.lock_outline_rounded,
                                      color: Colors.grey),
                                  labelText: 'Confirm Password'.tr,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        Singup_Controller1.Confirm_Password();
                                      });
                                    },
                                    icon: Singup_Controller1.passwordIcon2,
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF1A4C9C)),
                                  ),
                                ),
                                controller: password2,
                                validator: (v) =>
                                    Singup_Controller1.validatePassword(
                                        password.text, v, true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 13),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: GestureDetector(
                              child: Text(
                                'By signing up, you agree to our Terms & conditions and Privacy Policy'
                                    .tr,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              ),
                              onTap: () {},
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _loading ? null : register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1A4C9C),
                            minimumSize: const Size.fromHeight(45),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Center(
                                  child: Text("Sign Up".tr,
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.white))),
                        ),
                        const SizedBox(height: 25),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Joined us before?".tr,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey)),
                              const SizedBox(width: 6),
                              GestureDetector(
                                child: Text("Login".tr,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A4C9C))),
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const Login()));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
