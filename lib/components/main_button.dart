import 'package:flutter/material.dart';

enum ButtonSize { small, medium, large }

class MainButton extends StatelessWidget {
  final String title;
  final Function() onPressed;
  final double? width;
  final double? height;
  final ButtonSize size;

  const MainButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.width,
    this.height,
    this.size = ButtonSize.medium,
  });

  const MainButton.small({
    super.key,
    required this.title,
    required this.onPressed,
  }) : width = null,
       height = null,
       size = ButtonSize.small;

  const MainButton.large({
    super.key,
    required this.title,
    required this.onPressed,
  }) : width = null,
       height = null,
       size = ButtonSize.large;

  const MainButton.medium({
    super.key,
    required this.title,
    required this.onPressed,
  }) : width = null,
       height = null,
       size = ButtonSize.medium;

  @override
  Widget build(BuildContext context) {
    final double resolvedWidth = width ?? _widthFor(size);
    final double resolvedHeight = height ?? _heightFor(size);

    return SizedBox(
      width: resolvedWidth,
      height: resolvedHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: const Color(0xFF6BAB93),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          side: BorderSide(color: Colors.black, width: 1),
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'SoyoMaple',
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  double _widthFor(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 167;
      case ButtonSize.medium:
        return 320;
      case ButtonSize.large:
        return 347;
    }
  }

  double _heightFor(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 56;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 64;
    }
  }
}
