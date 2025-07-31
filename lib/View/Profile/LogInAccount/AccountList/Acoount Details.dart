import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'EditAccountPage.dart';

const Color primary = Color(0xFF1A4C9C);

Widget accountImage1({double size = 96}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [Color(0xFF1A4C9C), Color(0xFF3D6EB8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1A4C9C).withOpacity(.35),
          blurRadius: 18,
          offset: const Offset(0, 8),
        )
      ],
    ),
    child: const Icon(Icons.person_rounded, size: 54, color: Colors.white),
  );
}

class AcoountDetails extends StatefulWidget {
  const AcoountDetails({super.key});

  @override
  State<AcoountDetails> createState() => _AcoountDetailsState();
}

class _AcoountDetailsState extends State<AcoountDetails>
    with SingleTickerProviderStateMixin {
  static const Duration _animDur = Duration(milliseconds: 420);
  late AnimationController _floatingCtrl;

  @override
  void initState() {
    super.initState();
    _floatingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    // Simply triggering a rebuild causes FutureBuilder to fetch again
    setState(() {});
  }

  Future<Map<String, String>> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return {'fullName': '', 'email': '', 'phone': '','Grade':'', };
    }
    final doc = await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .get();
    final data = doc.data() ?? {};
    return {
      'fullName': (data['fullName'] as String?) ?? '',
      'email': (data['email'] as String?) ?? '',
      'phone': (data['phone'] as String?) ?? '',
      'Grade': (data['Grade'] as String?) ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final dir = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5FA),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Account Details'.tr,
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
            const _HeaderBackground(),
            RefreshIndicator(
              color: primary,
              onRefresh: _refresh,
              child: FutureBuilder<Map<String, String>>(
                future: getUserData(),
                builder: (context, snapshot) {
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: MediaQuery.of(context).padding.top + 140,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _buildProfileCard(snapshot),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 8),
                        sliver: SliverToBoxAdapter(
                          child: AnimatedSwitcher(
                            duration: _animDur,
                            child: _buildDataSection(snapshot),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: _buildEditButton(),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 42)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(AsyncSnapshot<Map<String, String>> snap) {
    final fullName = snap.data?['fullName'] ?? '';
    final email = snap.data?['email'] ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 70),
            padding: const EdgeInsets.fromLTRB(20, 62, 20, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withOpacity(.92),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
              border: Border.all(
                color: primary.withOpacity(.10),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  fullName.isEmpty ? '— —' : fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .3,
                    color: primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  email.isEmpty ? 'Not set'.tr : email,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(.55),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                _AnimatedBadges(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: AnimatedBuilder(
              animation: _floatingCtrl,
              builder: (context, child) {
                final dy = math.sin(_floatingCtrl.value * math.pi * 2) * 6;
                return Transform.translate(offset: Offset(0, dy), child: child);
              },
              child: Hero(
                tag: 'profile_avatar',
                child: accountImage1(size: 130),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(AsyncSnapshot<Map<String, String>> snap) {
    if (snap.connectionState == ConnectionState.waiting) {
      return const _LoadingSkeleton();
    }
    if (snap.hasError) {
      return Center(
        child: Text('Error loading data'.tr, style: const TextStyle(color: Colors.red)),
      );
    }
    final data = snap.data!;
    return Column(
      children: [
        _InfoTile(
          icon: Icons.person_outline_rounded,
          label: 'Full Name'.tr,
          value: data['fullName']!.isEmpty ? '— —' : data['fullName']!,
        ),
        const SizedBox(height: 18),
        _InfoTile(
          icon: Icons.school,
          label: 'Grade Level'.tr,
          value: data['Grade']!.isEmpty ? '— —' : data['Grade']!,
        ),
        const SizedBox(height: 18),
        _InfoTile(
          icon: Icons.email_outlined,
          label: 'Email'.tr,
          value: data['email']!.isEmpty ? 'Not set'.tr : data['email']!,
        ),
        const SizedBox(height: 18),
        _InfoTile(
          icon: Icons.phone_outlined,
          label: 'Phone'.tr,
          value: data['phone']!.isEmpty ? 'Not set'.tr : data['phone']!,
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () async {
          // load current data
          final data = await getUserData();
          // navigate and await the 'true' result from EditAccountPage
          final updated = await Get.to<bool>(
                () => EditAccountPage(
              initialName: data['fullName']!,
              initialPhone: data['phone']!,
              initialGrade: data['Grade']!,

            ),
            transition: Transition.fadeIn,
          );
          // if edit succeeded, refresh immediately
          if (updated == true) {
            _refresh();
          }
        },
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: Text(
          'Edit Information'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: .3,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
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
        height: 320,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A4C9C), Color(0xFF123869)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              left: -40,
              child: _circle(160, Colors.white.withOpacity(.06)),
            ),
            Positioned(
              bottom: 30,
              right: -50,
              child: _circle(220, Colors.white.withOpacity(.08)),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _circle(double size, Color color) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
);

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 90);
    final c1 = Offset(size.width * .25, size.height - 30);
    final e1 = Offset(size.width * .55, size.height - 60);
    p.quadraticBezierTo(c1.dx, c1.dy, e1.dx, e1.dy);
    final c2 = Offset(size.width * .80, size.height - 90);
    final e2 = Offset(size.width, size.height - 40);
    p.quadraticBezierTo(c2.dx, c2.dy, e2.dx, e2.dy);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1A4C9C);
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: primary.withOpacity(.12),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withOpacity(.25), width: 1),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primary.withOpacity(.85))),
                    const SizedBox(height: 4),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedBadges extends StatefulWidget {
  @override
  State<_AnimatedBadges> createState() => _AnimatedBadgesState();
}

class _AnimatedBadgesState extends State<_AnimatedBadges>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  final List<_BadgeItem> _badges = [
    _BadgeItem(Icons.verified_rounded, 'Verified'),
    _BadgeItem(Icons.security_rounded, 'Secure'),
    _BadgeItem(Icons.star_rounded, 'Member'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1A4C9C);
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: List.generate(_badges.length, (i) {
        final anim = CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i * .2, .6 + i * .2, curve: Curves.easeOutBack),
        );
        return ScaleTransition(
          scale: anim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withOpacity(.25), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_badges[i].icon, size: 16, color: primary),
                const SizedBox(width: 4),
                Text(_badges[i].label.tr,
                    style: const TextStyle(
                        color: primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .4)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _BadgeItem {
  final IconData icon;
  final String label;

  _BadgeItem(this.icon, this.label);
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  Widget _skeletonBar({double h = 16, double w = 140}) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.6),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _skeletonCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.55),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.6),
                  borderRadius: BorderRadius.circular(16))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBar(h: 12, w: 90),
                const SizedBox(height: 10),
                _skeletonBar(h: 18, w: 160),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _skeletonCard(),
        const SizedBox(height: 18),
        _skeletonCard(),
        const SizedBox(height: 18),
        _skeletonCard(),
      ],
    );
  }
}
