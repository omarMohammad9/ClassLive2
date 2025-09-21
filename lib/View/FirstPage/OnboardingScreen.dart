import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../Home/Home.dart';
import '../Profile/LogOutAccount/AccountList/Login-singup/Login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingItem {
  final String tag;
  final String title;
  final String desc;
  final String iconKey;
  _OnboardingItem({
    required this.tag,
    required this.title,
    required this.desc,
    required this.iconKey,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // استخدم viewportFraction لعرض جزء من الصفحة التالية
  final PageController _pageController = PageController(viewportFraction: 0.90);
  int _current = 0;

  // الهوية
  static const Color primary = Color(0xFF1A4C9C);
  static const Color primaryLight = Color(0xFF3D6EB8);
  static const Color primaryDark = Color(0xFF123869);
  static const Color accent = Color(0xFFF7B500);

  late final bool isArabic;

  @override
  void initState() {
    super.initState();
    isArabic = (Get.locale?.languageCode ?? 'en') == 'ar';
  }

  List<_OnboardingItem> get _items => isArabic
      ? [
    _OnboardingItem(
      tag: 'تعلم بحرية',
      title: 'محاضرات مسجَّلة شاملة',
      desc:
      'شاهد *محاضرات* كاملة عالية الجودة لمعظم المواد وقتما تشاء، وارجع لها أثناء المراجعة.',
      iconKey: 'lectures',
    ),
    _OnboardingItem(
      tag: 'مراجعة أسرع',
      title: 'مذكّرات ودوسيات جاهزة',
      desc:
      'استفد من *مذكّرات* منسَّقة تغطي أهم النقاط وتسهّل عليك الاستعداد للامتحانات.',
      iconKey: 'notes',
    ),
    _OnboardingItem(
      tag: 'ذكاء متطور',
      title: 'مساعد بالذكاء الاصطناعي',
      desc:
      'اطرح أسئلتك على *الذكاء الاصطناعي* لتحصل على شروحات وتلخيصات دقيقة فوراً.',
      iconKey: 'ai',
    ),
    _OnboardingItem(
      tag: 'دفع آمن',
      title: 'شراء آمن وسهل',
      desc:
      'ادفع عبر *Google Play* و *App Store* بثقة، وابدأ بالتعلم مباشرة بعد الشراء.',
      iconKey: 'payment',
    ),
  ]
      : [
    _OnboardingItem(
      tag: 'Learn Freely',
      title: 'Comprehensive Recorded Lectures',
      desc:
      'Access full high-quality *lectures* for most subjects anytime—rewatch & revise.',
      iconKey: 'lectures',
    ),
    _OnboardingItem(
      tag: 'Faster Revision',
      title: 'Curated Study Notes',
      desc:
      'Use structured *notes* covering key points to speed up effective revision sessions.',
      iconKey: 'notes',
    ),
    _OnboardingItem(
      tag: 'Smart Support',
      title: 'AI-Powered Assistant',
      desc:
      'Ask the *AI assistant* for instant explanations, clarifications, and summaries.',
      iconKey: 'ai',
    ),
    _OnboardingItem(
      tag: 'Secure Billing',
      title: 'Secure & Easy Purchase',
      desc:
      'Purchase safely via *Google Play* & *App Store* and start learning immediately.',
      iconKey: 'payment',
    ),
  ];

  void _next() {
    if (_current < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_current > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _finish() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Get.offAll(() => const Home(), transition: Transition.fadeIn);
    } else {
      Get.offAll(() => const Login(), transition: Transition.fadeIn);
    }
  }


  @override
  Widget build(BuildContext context) {
    final dir = isArabic ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(
      textDirection: dir,
      child: Scaffold(
        body: Stack(
          children: [
            // خلفية متدرجة مع رسم زخرفي
            const _BackgroundLayer(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProgressBar(),
                  Expanded(child: _buildPageView()),
                  const SizedBox(height: 10),
                  _buildIndicator(),
                  const SizedBox(height: 22),
                  _buildBottomButtons(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Row(
        children: [
          Text(
            'ClassLive',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
          const Spacer(),
          if (_current > 0)

          if (_current < _items.length - 1)
            TextButton(
              onPressed: () => _pageController.animateToPage(
                _items.length - 1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              ),
              child: Text(
                isArabic ? 'تخطي' : 'Skip',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_current + 1) / _items.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: Colors.white.withOpacity(.20),
          valueColor: const AlwaysStoppedAnimation(accent),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      itemCount: _items.length,
      onPageChanged: (i) => setState(() => _current = i),
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double page = 0;
            if (_pageController.position.haveDimensions) {
              page = _pageController.page ?? _pageController.initialPage.toDouble();
            } else {
              page = _current.toDouble();
            }
            final diff = (page - index);
            final scale = (1.0 - (diff.abs() * 0.10).clamp(0.0, 0.10)).toDouble();
            final opacity = (1 - diff.abs() * 0.55).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: _ParallaxCard(
                  item: _items[index],
                  progress: diff,
                  isArabic: isArabic,
                  isLast: index == _items.length - 1,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIndicator() {
    return SmoothPageIndicator(
      controller: _pageController,
      count: _items.length,
      effect: ExpandingDotsEffect(
        activeDotColor: accent,
        dotColor: Colors.white.withOpacity(.35),
        dotHeight: 10,
        dotWidth: 10,
        expansionFactor: 3,
        spacing: 6,
      ),
    );
  }

  Widget _buildBottomButtons() {
    final isLast = _current == _items.length - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        children: [
          Expanded(
            child: AnimatedOpacity(
              opacity: _current > 0 ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: _current > 0
                  ? OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: Colors.white.withOpacity(.65),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _back,
                child: Text(
                  isArabic ? 'رجوع' : 'Back',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ),
          if (_current > 0) const SizedBox(width: 14),
          Expanded(
            flex: isLast ? 2 : 3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? accent : Colors.white,
                elevation: 6,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: _next,
              child: Text(
                isLast
                    ? (isArabic ? 'ابدأ الآن' : 'Get Started')
                    : (isArabic ? 'التالي' : 'Next'),
                style: TextStyle(
                  color: isLast ? Colors.black : primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// الخلفية (تدرج + أشكال دائرية)
class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer({super.key});
  static const Color primary = Color(0xFF1A4C9C);
  static const Color primaryLight = Color(0xFF3D6EB8);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _BgPainter(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(7);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withOpacity(.18);

    for (int i = 0; i < 6; i++) {
      final cx = rnd.nextDouble() * size.width;
      final cy = rnd.nextDouble() * size.height * 0.9;
      final r = 80 + rnd.nextDouble() * 140;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// بطاقة بارالاكس
class _ParallaxCard extends StatelessWidget {
  final _OnboardingItem item;
  final double progress;
  final bool isArabic;
  final bool isLast;

  static const Color primary = Color(0xFF1A4C9C);
  static const Color primaryLight = Color(0xFF3D6EB8);
  static const Color primaryDark = Color(0xFF123869);
  static const Color accent = Color(0xFFF7B500);

  const _ParallaxCard({
    required this.item,
    required this.progress,
    required this.isArabic,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final dirFactor = isArabic ? -1.0 : 1.0;

    final iconOffsetX = (progress * 28 * dirFactor);
    final textOffsetX = (progress * 55 * dirFactor);
    final iconRotation = progress * 0.07;
    final tagOffsetX = progress * 22 * dirFactor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          children: [
            // خلفية داخلية متدرجة + Overlay آخر شفاف
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFFEDF3FA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            if (isLast)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accent.withOpacity(.08),
                        accent.withOpacity(.02),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 42, 28, 46),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(tagOffsetX, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(.08),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: primary.withOpacity(.15),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item.tag.toUpperCase(),
                        style: TextStyle(
                          color: primaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Transform.translate(
                    offset: Offset(iconOffsetX, 0),
                    child: Transform.rotate(
                      angle: iconRotation,
                      child: Container(
                        height: 96,
                        width: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              primary.withOpacity(.10),
                              primaryLight.withOpacity(.20),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: primary.withOpacity(.25),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _resolveIcon(item.iconKey),
                          size: 50,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Transform.translate(
                    offset: Offset(textOffsetX, 0),
                    child: Column(
                      children: [
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: primary,
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _AnimatedUnderline(
                          active: true,
                          color: isLast ? accent : primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Transform.translate(
                    offset: Offset(textOffsetX * 1.15, 0),
                    child: _RichDesc(text: item.desc),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedUnderline extends StatelessWidget {
  final bool active;
  final Color color;
  const _AnimatedUnderline({super.key, required this.active, required this.color});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      height: 4,
      width: active ? 64 : 0,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _RichDesc extends StatelessWidget {
  final String text;
  static const Color primaryDark = Color(0xFF123869);
  static const Color accent = Color(0xFFF7B500);
  const _RichDesc({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final parts = text.split('*');
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: List.generate(parts.length, (i) {
          final seg = parts[i];
          final highlight = i.isOdd;
          if (!highlight) {
            return TextSpan(
              text: seg,
              style: TextStyle(
                fontSize: 15.5,
                height: 1.55,
                fontWeight: FontWeight.w500,
                color: primaryDark.withOpacity(.80),
              ),
            );
          }
          return WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withOpacity(.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                seg.trim(),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: primaryDark,
                  height: 1.2,
                  letterSpacing: .3,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// أيقونات
IconData _resolveIcon(String key) {
  switch (key) {
    case 'lectures':
      return Icons.play_circle_fill_rounded;
    case 'notes':
      return Icons.menu_book_rounded;
    case 'ai':
      return Icons.smart_toy_rounded;
    case 'payment':
      return Icons.verified_user_rounded;
    default:
      return Icons.auto_awesome;
  }
}
