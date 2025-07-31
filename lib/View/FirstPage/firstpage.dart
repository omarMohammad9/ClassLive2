import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home/Home.dart';
import 'SecondPage-Language.dart';

class firstpage extends StatefulWidget {
  const firstpage({super.key});

  @override
  State<firstpage> createState() => _FirstPageState();
}

class _FirstPageState extends State<firstpage> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _checkLanguageChosen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  Future<void> _checkLanguageChosen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLanguageChosen = prefs.getBool('isLanguageChosen');
    await Future.delayed(const Duration(seconds: 5), () {
      Get.offAll(isLanguageChosen == true ?  Home() : const LanguageScreenModern(),transition: Transition.fadeIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 8,
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(seconds: 3),
                child: const Image(
                  image: AssetImage("images/LogoApp.png"),
                ),
              ),
            ),
            Expanded(
              child: Text(
                "Welcome",
                style: TextStyle(color: Color(0xFF1A4C9C),fontWeight:FontWeight.bold  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
