// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class accountImage extends StatefulWidget {
  @override
  const accountImage({super.key});

  @override
  State<accountImage> createState() => accountImage1();
}

class accountImage1 extends State<accountImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 195,
        decoration:  BoxDecoration(
           color:Color(0xFF1A4C9C)),
        child: Center(
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(75)),
              child: SizedBox(
                width: 110,
                height: 110,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(75),
                    child: Image.asset(
                      "images/account.png",
                      fit: BoxFit.cover,
                    )),
              ),
            ),

        ));
  }
}
