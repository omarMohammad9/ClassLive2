import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _loading        = false;

  late AnimationController _iconAnim;

  @override
  void initState() {
    super.initState();
    _iconAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _newCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _iconAnim.dispose();
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ================== منطق قوة كلمة المرور ==================
  double get _strength {
    final p = _newCtrl.text;
    if (p.isEmpty) return 0;
    double s = 0;
    if (p.length >= 6) s += .25;
    if (p.length >= 10) s += .20;
    if (RegExp(r'[A-Z]').hasMatch(p)) s += .15;
    if (RegExp(r'[0-9]').hasMatch(p)) s += .15;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(p)) s += .15;
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(p)) s += .10;
    return s.clamp(0, 1);
  }

  String get _strengthLabel {
    final v = _strength;
    if (v == 0) return '';
    if (v < .35) return 'Weak'.tr;
    if (v < .65) return 'Medium'.tr;
    if (v < .85) return 'Strong'.tr;
    return 'Very Strong'.tr;
  }

  Color get _strengthColor {
    final v = _strength;
    if (v == 0) return Colors.grey;
    if (v < .35) return Colors.redAccent;
    if (v < .65) return Colors.orange;
    if (v < .85) return Colors.lightGreen;
    return Colors.green;
  }

  // ================== تنفيذ التحديث عبر Firebase ==================
  Future<void> _performUpdate() async {
    if (_loading) return;
    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'Error'.tr,
        'No user logged in'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() => _loading = false);
      return;
    }

    try {
      // 1) إعادة التحقق (Re-authenticate)
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentCtrl.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);

      // 2) تحديث كلمة المرور
      await user.updatePassword(_newCtrl.text.trim());

      // نجاح
      Get.snackbar(
        'Success'.tr,
        'Password updated successfully!'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'wrong-password') {
        message = 'Current password is incorrect'.tr;
      } else if (e.code == 'weak-password') {
        message = 'The new password is too weak'.tr;
      } else {
        message = 'Could not update password: ${e.message}'.tr;
      }
      Get.snackbar(
        'Error'.tr,
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        'Error'.tr,
        'An unexpected error occurred'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _performUpdate();
    }
  }

  void _toggle(TextEditingController ctrl) {
    setState(() {
      if (ctrl == _currentCtrl) _obscureCurrent = !_obscureCurrent;
      if (ctrl == _newCtrl)     _obscureNew     = !_obscureNew;
      if (ctrl == _confirmCtrl) _obscureConfirm = !_obscureConfirm;
    });
  }

  InputDecoration _dec({
    required String label,
    required bool obscure,
    required TextEditingController ctrl,
    IconData icon = Icons.lock_outline_rounded,
  }) {
    return InputDecoration(
      labelText: label.tr,
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: () => _toggle(ctrl),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(.85),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: const Color(0xFF1A4C9C).withOpacity(.25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: const Color(0xFF1A4C9C).withOpacity(.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
        const BorderSide(color: Color(0xFF1A4C9C), width: 1.4),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1A4C9C);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Change Password'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: .5,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // خلفية متدرجة
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1A4C9C),
                    Color(0xFF123869),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // دوائر زخرفية
          Positioned(
            top: -60,
            left: -40,
            child: _circle(180, primary.withOpacity(.15)),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: _circle(160, Colors.white.withOpacity(.08)),
          ),
          // المحتوى
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: kToolbarHeight +
                    MediaQuery.of(context).padding.top +
                    24,
                left: 20,
                right: 20,
                bottom: 34,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding:
                        const EdgeInsets.fromLTRB(26, 30, 26, 34),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: Colors.white.withOpacity(.75),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.08),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                          border: Border.all(
                              color: primary.withOpacity(.15),
                              width: 1),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _animatedIcon(primary),
                              const SizedBox(height: 18),
                              Text(
                                'Keep your account secure'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                  primary.withOpacity(.85),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                controller: _currentCtrl,
                                obscureText: _obscureCurrent,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please enter your current password'
                                        .tr;
                                  }
                                  if (v.length < 6) {
                                    return 'Invalid current password'.tr;
                                  }
                                  return null;
                                },
                                decoration: _dec(
                                  label: 'Current Password',
                                  obscure: _obscureCurrent,
                                  ctrl: _currentCtrl,
                                  icon: Icons.lock_clock_outlined,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _newCtrl,
                                obscureText: _obscureNew,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Enter new password'.tr;
                                  }
                                  if (v.length < 6) {
                                    return 'Must be at least 6 characters'
                                        .tr;
                                  }
                                  if (v == _currentCtrl.text) {
                                    return 'New password must differ from current'
                                        .tr;
                                  }
                                  return null;
                                },
                                decoration: _dec(
                                  label: 'New Password',
                                  obscure: _obscureNew,
                                  ctrl: _newCtrl,
                                  icon: Icons.vpn_key_rounded,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _passwordStrength(primary),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscureConfirm,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Confirm password'.tr;
                                  }
                                  if (v != _newCtrl.text) {
                                    return 'Passwords do not match'.tr;
                                  }
                                  return null;
                                },
                                decoration: _dec(
                                  label: 'Confirm New Password',
                                  obscure: _obscureConfirm,
                                  ctrl: _confirmCtrl,
                                  icon:
                                  Icons.verified_user_outlined,
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed:
                                  _loading ? null : _submit,
                                  style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    elevation: 6,
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          16),
                                    ),
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 14),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                    width: 26,
                                    height: 26,
                                    child:
                                    CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                      : Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                    children: [
                                      const Icon(
                                        Icons.save_rounded,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                          width: 10),
                                      Text(
                                        'Update Password'.tr,
                                        style:
                                        const TextStyle(
                                          color:
                                          Colors.white,
                                          fontSize: 17,
                                          fontWeight:
                                          FontWeight
                                              .w700,
                                          letterSpacing: .3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Use a strong unique password with letters, numbers & symbols.'
                                    .tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.black
                                      .withOpacity(.55),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedIcon(Color primary) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.94, end: 1.05).animate(
        CurvedAnimation(parent: _iconAnim, curve: Curves.easeInOut),
      ),
      child: Container(
        height: 74,
        width: 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              primary.withOpacity(.85),
              const Color(0xFF123869),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.lock_reset_rounded,
          size: 34,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _passwordStrength(Color primary) {
    if (_newCtrl.text.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              colors: [
                _strengthColor.withOpacity(.85),
                _strengthColor.withOpacity(.55),
              ],
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _strength,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _strengthColor,
                    _strengthColor.withOpacity(.7),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              _strength >= .65
                  ? Icons.check_circle_rounded
                  : Icons.lock_outline_rounded,
              size: 18,
              color: _strengthColor,
            ),
            const SizedBox(width: 6),
            Text(
              _strengthLabel,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _strengthColor,
              ),
            ),
            const Spacer(),
            if (_strength < .65)
              Text(
                'Add more variety...'.tr,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(.5),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

Widget _circle(double size, Color color) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
);
