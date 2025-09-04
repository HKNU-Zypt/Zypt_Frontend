import 'package:flutter/material.dart';

class StatItem {
  final String label;
  final String value;
  final bool emphasize; // 값 볼드 강조 여부
  const StatItem(this.label, this.value, {this.emphasize = true});
}

/// 카드 컴포넌트
class StatsCard extends StatelessWidget {
  final List<StatItem> items;
  final double radius;
  final double borderWidth;
  final double outlineOffset; // px 기준 오프셋
  final EdgeInsets padding;
  final Color background;
  final Color borderColor;

  const StatsCard({
    super.key,
    required this.items,
    this.radius = 28,
    this.borderWidth = 1.6,
    this.outlineOffset = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    this.background = Colors.white,
    this.borderColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        clipBehavior: Clip.none, // 밀린 외곽선이 잘리지 않도록
        children: [
          // 외곽선: 본 카드와 '같은 크기'로 채운 뒤 살짝 밀기
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(outlineOffset, outlineOffset),
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: br,
                    border: Border.all(
                      color: Colors.black.withAlpha(200),
                      width: borderWidth,
                    ),
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
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12,
                  offset: Offset(0, 2),
                  color: Color(0x1A000000),
                ),
              ],
            ),
            padding: padding,
            child: _buildRows(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRows(BuildContext context) {
    const rowGap = 18.0;
    final labelStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.1,
    );
    final valueStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      height: 1.1,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(items[i].label, style: labelStyle)),
              const SizedBox(width: 16),
              Text(
                items[i].value,
                style: items[i].emphasize ? valueStyle : labelStyle,
                textAlign: TextAlign.right,
              ),
            ],
          ),
          if (i != items.length - 1) const SizedBox(height: rowGap),
        ],
      ],
    );
  }
}
