import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home/Home.dart';
import '../My Courses/My Courses.dart';
import '../Profile/LogInAccount/home page.dart';
import '../Quizzes/Quizzes.dart';

class BottomNavigation extends StatefulWidget {
  final int selectedIndex;

  const BottomNavigation({
    super.key,
    this.selectedIndex = 0,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late int _selectedIndex;

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void navigateTo(int index) {
    if (_selectedIndex != index) {
      Widget nextPage;
      switch (index) {
        case 2:
          nextPage = Home();
          break;
        case 3:
          nextPage = Quizzes();
        case 5:
          nextPage = My_Courses();
          break;
        case 4:
          nextPage = personal();
          break;
        default:
          nextPage = Home();
      }

      Get.offAll(
        () => nextPage,
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      )?.then((result) {
        if (result != null && result is int) {
          setState(() {
            _selectedIndex = result;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Color(0xFF1A4C9C),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildNavIcon(Icons.home, Icons.home_outlined, 2, "Home".tr),
          buildNavIcon(Icons.library_books, Icons.library_books_outlined, 5, "My Courses".tr),



          buildNavIcon(
              Icons.assignment, Icons.assignment_outlined, 3, "Quizzes".tr),
          buildNavIcon(Icons.account_circle, Icons.account_circle_outlined, 4,
              "Profile".tr),
        ],
      ),
    );
  }

  Widget buildNavIcon(
      IconData icon, IconData outlinedIcon, int index, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => navigateTo(index),
          child: Column(
            children: [
              Icon(
                _selectedIndex == index ? icon : outlinedIcon,
                size: 32,
                color: Colors.white,
              ),
              SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
