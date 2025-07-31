import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ss122/View/FirstPage/firstpage.dart';

import '../../../../locale/localeController.dart';



class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _Language();
}

class _Language extends State<Language> {
  static const primaryColor = Color(0xFF1A4C9C);
  String _selected = Get.locale?.languageCode ?? 'en';

  Future<void> _apply() async {
    final c = Get.find<MyLocaleController>();
    c.changelang(_selected);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLanguageChosen', true);
    Get.offAll(() =>  firstpage(), transition: Transition.fadeIn);
  }

  Widget _card({
    required String code,
    required String titleAr,
    required String titleEn,
  }) {
    final bool isSelected = _selected == code;
    return InkWell(
      onTap: () => setState(() => _selected = code),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.10 : 0.04),
              blurRadius: isSelected ? 18 : 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Badge
            Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                code.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.2,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Text (محاذاة يسار دائماً قرب الشارة)
            Expanded(
              child: Text(
                code == 'ar' ? titleAr : titleEn,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isSelected
                  ? const Icon(Icons.radio_button_checked,
                  key: ValueKey('on'), color: primaryColor, size: 26)
                  : const Icon(Icons.radio_button_off,
                  key: ValueKey('off'), color: Colors.grey, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar:AppBar(backgroundColor:Colors.transparent ,) ,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Image.asset('images/6435775-removebg-preview.png', height: 95),
                  const SizedBox(height: 28),
                  Text(
                    'Choose Language'.tr,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select your preferred language',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 34),
                  _card(code: 'ar', titleAr: 'العربية', titleEn: 'Arabic'),
                  const SizedBox(height: 16),
                  _card(code: 'en', titleAr: 'English', titleEn: 'English'),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _apply,
                      child: Text(
                        _selected == 'ar' ? 'متابعة' : 'Continue',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
