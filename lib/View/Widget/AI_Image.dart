import 'package:flutter/material.dart';

class GifFloatingActionButton extends StatelessWidget {
  const GifFloatingActionButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
        scale: 1.2,
        child: Image.asset(
          "assets/ss.gif",
          fit: BoxFit.cover,
        ),
      );
  }
}
