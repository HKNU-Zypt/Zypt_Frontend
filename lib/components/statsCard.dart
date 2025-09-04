import 'package:flutter/material.dart';

class OffsetOutlinedCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final double borderWidth;
  final double outlineOffset;
  final EdgeInsets padding; // 카드 내부 여백
  final EdgeInsets outerPadding; // 카드 바깥 여백
  final Color background;
  final Color borderColor;
  final Color outlineColor;
  final List<BoxShadow> boxShadow;
  final bool clipInner; // 내부를 라운드에 맞춰 클립할지

  const OffsetOutlinedCard({
    super.key,
    required this.child,
    this.radius = 28,
    this.borderWidth = 1.6,
    this.outlineOffset = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    this.outerPadding = const EdgeInsets.symmetric(horizontal: 15),
    this.background = Colors.white,
    this.borderColor = Colors.black87,
    this.outlineColor = const Color.fromARGB(200, 0, 0, 0),
    this.boxShadow = const [
      BoxShadow(blurRadius: 12, offset: Offset(0, 2), color: Color(0x1A000000)),
    ],
    this.clipInner = false,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);

    Widget inner = child;
    if (clipInner) {
      inner = ClipRRect(borderRadius: br, child: child);
    }

    return Padding(
      padding: outerPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 뒤로 밀린 외곽선(본 카드와 동일 크기)
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(outlineOffset, outlineOffset),
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: br,
                    border: Border.all(color: outlineColor, width: borderWidth),
                  ),
                ),
              ),
            ),
          ),
          // 본 카드
          Container(
            decoration: BoxDecoration(
              color: background,
              borderRadius: br,
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: boxShadow,
            ),
            padding: padding,
            child: inner,
          ),
        ],
      ),
    );
  }
}
