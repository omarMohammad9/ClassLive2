import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color primary = Color(0xFF1A4C9C);
const Color primaryDark = Color(0xFF123869);

class EditAccountPage extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialGrade;

  const EditAccountPage({
    Key? key,
    required this.initialName,
    required this.initialPhone,
    required this.initialGrade,
  }) : super(key: key);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _saving = false;
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

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
    selectedGrade = widget.initialGrade;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await FirebaseFirestore.instance.collection('User').doc(uid).update({
        'fullName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'Grade': selectedGrade,
      });
      Get.back(result: true);
      Get.snackbar(
        'Success'.tr,
        'Profile updated'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (_) {
      Get.snackbar(
        'Error'.tr,
        'Could not save changes'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Stack(
        children: [
          const _HeaderBackground(),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Profile'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Full Name'.tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Please enter your name'.tr
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone'.tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              final input = v?.trim() ?? '';
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your phone'.tr;
                              }
                              if (input.length != 10) {
                                return 'Enter a valid phone number'.tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  "Choose Your Grade :".tr,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Padding(
                            padding: const EdgeInsets.only(right: 3, left: 3),
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
                                    hint: Text("$selectedGrade"),
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
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _saving
                                  ? const CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    )
                                  : Text(
                                      'Save Changes'.tr,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: 240,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 60);
    final c1 = Offset(size.width * 0.25, size.height);
    final e1 = Offset(size.width * 0.5, size.height - 40);
    p.quadraticBezierTo(c1.dx, c1.dy, e1.dx, e1.dy);
    final c2 = Offset(size.width * 0.75, size.height - 80);
    final e2 = Offset(size.width, size.height - 20);
    p.quadraticBezierTo(c2.dx, c2.dy, e2.dx, e2.dy);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}
