// ignore_for_file: file_names, camel_case_types


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ss122/View/Widget/AI_Image.dart';
import '../../../Ai_chat/AI-chat.dart';
import '../../../BottomNavigation/bottomNavigation.dart';
import 'accountList.dart';



class accountHome extends StatefulWidget {
  @override
  const accountHome({super.key});

  @override
  State<accountHome> createState() => accountHome1();
}

class accountHome1 extends State<accountHome> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 7,
          right: 7,
          bottom: 16,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BottomNavigation(
            selectedIndex: 4,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () {
            Get.to(Ai_chat(), transition: Transition.downToUp);
          },
          child: GifFloatingActionButton(),
          backgroundColor: Colors.transparent,
          shape: CircleBorder(),
          elevation: 0,
        ),
      ),
      appBar: AppBar(
        backgroundColor:Color(0xFF1A4C9C),
        title: Text("MyProfile".tr,
            style:  TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: Container(
        child: const accountList(),
      ),
    );
  }
}
