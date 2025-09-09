import 'package:flutter/material.dart';

class BoxDesign extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundcolor;
  final Color designcolor;
  final Widget child;

  const BoxDesign({
    super.key,
    required this.backgroundcolor,
    required this.designcolor,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: Transform.translate(
            offset: Offset(5, 5),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: designcolor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black),
              ),
            ),
          ),
        ),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundcolor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black),
          ),
          child: child,
        ),
      ],
    );
  }
}
