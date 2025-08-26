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
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
        return 60;
      case ButtonSize.medium:
        return 60;
      case ButtonSize.large:
        return 68;
    }
  }
}
