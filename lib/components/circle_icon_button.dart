import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 36,
    this.iconSize = 28,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.borderColor,
    this.borderWidth = 1.5,
    this.padding,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor ?? Colors.transparent,
              width: borderColor == null ? 0 : borderWidth,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}
