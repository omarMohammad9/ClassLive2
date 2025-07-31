import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss122/View/Home/Home.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage>
    with TickerProviderStateMixin {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();

  // State
  bool _obscure = true;
  bool _submitting = false;

  // Animations
  late final AnimationController _pulseCtrl;
  late final AnimationController _bgFloatCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _bgFloatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _bgFloatCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ================== Submit / Flow ==================
  void _toggleObscure() => setState(() => _obscure = !_obscure);

  Future<void> _startDeletionFlow() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final first = await _showFirstConfirmDialog();
    if (first != true) return;
    final finalConfirm = await _showFinalDangerDialog();
    if (finalConfirm != true) return;
    await _performDeletion();
  }

  Future<bool?> _showFirstConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ThemedDialog(
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.orange,
        title: 'delete_account_confirm_title'.tr,
        message: 'delete_account_confirm_msg'.tr,
        primaryLabel: 'continue'.tr,
        secondaryLabel: 'cancel'.tr,
        onPrimary: () => Navigator.of(context).pop(true),
        onSecondary: () => Navigator.of(context).pop(false),
      ),
    );
  }

  Future<bool?> _showFinalDangerDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ThemedDialog(
        icon: Icons.delete_forever_rounded,
        iconColor: Colors.redAccent,
        title: 'delete_account_final_title'.tr,
        message: 'delete_account_final_msg'.tr,
        primaryLabel: 'delete_now'.tr,
        secondaryLabel: 'back'.tr,
        danger: true,
        onPrimary: () => Navigator.of(context).pop(true),
        onSecondary: () => Navigator.of(context).pop(false),
      ),
    );
  }

  Future<void> _performDeletion() async {
    setState(() => _submitting = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error'.tr, 'No user logged in'.tr,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      setState(() => _submitting = false);
      return;
    }
    try {
      // Re-authenticate
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: _passwordCtrl.text.trim());
      await user.reauthenticateWithCredential(cred);

      // Delete Firestore document
      await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .delete();

      // Delete Auth account
      await user.delete();

      // Success dialog
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => _ThemedDialog(
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
          title: 'delete_success_title'.tr,
          message: 'delete_success_msg'.tr,
          primaryLabel: 'ok'.tr,
          onPrimary: () => Navigator.of(context).pop(),
        ),
      );
      await FirebaseAuth.instance.signOut();
      Get.offAll(Home());

    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'wrong-password') {
        msg = 'delete_account_password_error'.tr;
      } else if (e.code == 'requires-recent-login') {
        msg = 'Please re-login and try again.'.tr;
      } else {
        msg = e.message ?? 'delete_error_generic'.tr;
      }
      Get.snackbar('Error'.tr, msg,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (_) {
      Get.snackbar('Error'.tr, 'delete_error_generic'.tr,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final dir = isArabic ? TextDirection.rtl : TextDirection.ltr;
    const primary = Color(0xFF1A4C9C);

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'account settings'.tr,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            _AnimatedBackground(controller: _bgFloatCtrl),
            _buildContent(primary),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color primary) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 34,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: _glassCard(primary),
        ),
      ),
    );
  }

  Widget _glassCard(Color primary) => ClipRRect(
    borderRadius: BorderRadius.circular(40),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 34, 28, 34),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.white.withOpacity(.78),
          border:
          Border.all(color: Colors.white.withOpacity(.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _pulseWarningIcon(primary),
              const SizedBox(height: 18),
              Text(
                'delete account heading'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: primary,
                  letterSpacing: .3,
                ),
              ),
              const SizedBox(height: 14),
              _richWarningText(),
              const SizedBox(height: 32),
              _buildSteps(),
              const SizedBox(height: 26),
              _buildPasswordField(primary),
              const SizedBox(height: 34),
              _actionButtons(primary),
              const SizedBox(height: 18),
              _disclaimer(primary),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _pulseWarningIcon(Color primary) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
      ),
      child: Container(
        height: 92,
        width: 92,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [primary, const Color(0xFF123869)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(.45),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.delete_outline_rounded,
            size: 48, color: Colors.white),
      ),
    );
  }

  Widget _richWarningText() {
    final text = 'delete account warning rich'.tr;
    final parts = text.split('*');
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: List.generate(parts.length, (i) {
          final highlight = i.isOdd;
          return TextSpan(
            text: parts[i],
            style: TextStyle(
              fontSize: 15.5,
              height: 1.55,
              color: Colors.black87,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSteps() {
    final steps = [
      ('backup'.tr, Icons.cloud_download_outlined),
      ('review'.tr, Icons.visibility_outlined),
      ('confirm'.tr, Icons.verified_user_outlined),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (i) {
        final active = true; // always show all steps as completed
        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: active
                      ? const LinearGradient(
                    colors: [Color(0xFF1A4C9C), Color(0xFF3D6EB8)],
                  )
                      : null,
                  color: active ? null : Colors.grey.shade300,
                  boxShadow: active
                      ? [
                    BoxShadow(
                      color: const Color(0xFF1A4C9C).withOpacity(.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Icon(
                  steps[i].$2,
                  size: 22,
                  color: active ? Colors.white : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                steps[i].$1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? const Color(0xFF1A4C9C)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPasswordField(Color primary) {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscure,
      validator: (v) {
        if (v == null || v.isEmpty) return 'delete account password error'.tr;
        if (v.length < 6) return 'Minimum 6 characters'.tr;
        return null;
      },
      decoration: InputDecoration(
        labelText: 'delete account password'.tr,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: _toggleObscure,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary.withOpacity(.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary.withOpacity(.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1A4C9C), width: 1.4),
        ),
      ),
    );
  }

  Widget _actionButtons(Color primary) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: primary.withOpacity(.45), width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitting ? null : _startDeletionFlow,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 6,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.redAccent.withOpacity(.45),
            ),
            child: _submitting
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_forever_rounded,
                    color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'delete account'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: .4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _disclaimer(Color primary) {
    return Text(
      'delete_account_disclaimer'.tr,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11.5,
        height: 1.4,
        color: primary.withOpacity(.65),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ================== Animated Background ==================
class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A4C9C), Color(0xFF123869)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              _movingCircle(180, Offset(
                math.sin(t * math.pi * 2) * 40 + 20,
                120 + math.cos(t * math.pi * 2) * 30,
              ), Colors.white.withOpacity(.06)),
              _movingCircle(220, Offset(
                -30 + math.cos(t * math.pi * 2) * 50,
                300 + math.sin(t * math.pi * 2) * 40,
              ), Colors.white.withOpacity(.07)),
              _movingCircle(140, Offset(
                260 + math.sin(t * math.pi * 2) * 35,
                430 + math.cos(t * math.pi * 2) * 25,
              ), Colors.white.withOpacity(.05)),
            ],
          ),
        );
      },
    );
  }

  Widget _movingCircle(double size, Offset offset, Color color) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

// ================== Reusable Dialog ==================
class _ThemedDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final bool danger;

  const _ThemedDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.primaryLabel,
    this.secondaryLabel,
    required this.onPrimary,
    this.onSecondary,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1A4C9C);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Column(
        children: [
          Container(
            height: 66,
            width: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(.12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 34, color: iconColor),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: danger ? Colors.redAccent : primary,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14.5,
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        if (secondaryLabel != null)
          TextButton(
            onPressed: onSecondary,
            child: Text(
              secondaryLabel!,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ElevatedButton(
          onPressed: onPrimary,
          style: ElevatedButton.styleFrom(
            backgroundColor: danger ? Colors.redAccent : primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          child: Text(
            primaryLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
            ),
          ),
        ),
      ],
    );
  }
}
