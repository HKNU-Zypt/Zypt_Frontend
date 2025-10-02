import 'dart:math' as math;
import 'package:flutter/material.dart';

class TimeInterval {
  final DateTime start;
  final DateTime end;
  const TimeInterval(this.start, this.end);
}

class FocusTimelineBar extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final List<TimeInterval> unfocused;
  final double height;
  final double trackHeight;
  final double radius;
  final EdgeInsets padding;
  final Color baseColor;
  final Color segmentColor;
  final Color endpointColor;
  final Color markerFill;
  final Color markerBorder;
  final bool isResult;

  // NEW: 집중X 구간 라벨 표시 여부
  final bool showUnfocusedLabels;

  const FocusTimelineBar({
    super.key,
    required this.start,
    required this.end,

    this.unfocused = const [],
    this.height = 88,
    this.trackHeight = 2,
    this.radius = 5,
    this.padding = const EdgeInsets.fromLTRB(5, 15, 5, 14),
    this.baseColor = const Color(0xFF6BAB93), // 전체 라인
    this.segmentColor = const Color(0xFFF95C3B), // 집중X 구간
    this.endpointColor = const Color(0xFF6BAB93), // 양끝 점
    this.markerFill = const Color(0xFFF95C3B), // 집중X 구간 경계
    this.markerBorder = const Color(0xFFF95C3B),
    // 기본값: 집중X 구간 라벨 숨김
    this.showUnfocusedLabels = false,
    this.isResult = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _FocusTimelinePainter(
          start: start,
          end: end,
          unfocused: unfocused,
          trackHeight: trackHeight,
          radius: radius,
          padding: padding,
          baseColor: baseColor,
          segmentColor: segmentColor,
          endpointColor: endpointColor,
          markerFill: markerFill,
          markerBorder: markerBorder,
          showUnfocusedLabels: showUnfocusedLabels, // ← 전달
          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: Colors.black87,
            fontFamily: 'AppleSDGothicNeo',
          ),
          isResult: isResult,
        ),
      ),
    );
  }
}

class _FocusTimelinePainter extends CustomPainter {
  final DateTime start, end;
  final List<TimeInterval> unfocused;
  final double trackHeight, radius;
  final EdgeInsets padding;
  final Color baseColor, segmentColor, endpointColor, markerFill, markerBorder;
  final TextStyle? textStyle;
  final bool showUnfocusedLabels; // NEW
  final bool isResult; // 결과 화면 여부 (라벨 위치 조정용)

  _FocusTimelinePainter({
    required this.start,
    required this.end,
    required this.unfocused,
    required this.trackHeight,
    required this.radius,
    required this.padding,
    required this.baseColor,
    required this.segmentColor,
    required this.endpointColor,
    required this.markerFill,
    required this.markerBorder,
    required this.textStyle,
    required this.showUnfocusedLabels, // NEW
    this.isResult = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final left = padding.left + radius;
    final right = size.width - padding.right - radius;
    final y = padding.top + trackHeight / 2;
    final labelY = size.height - padding.bottom;

    final totalSec = math.max(1, end.difference(start).inSeconds);
    double toX(DateTime t) {
      final sec = (t.difference(start).inSeconds).clamp(0, totalSec);
      final frac = sec / totalSec;
      return left + (right - left) * frac;
    }

    final base =
        Paint()
          ..color = baseColor
          ..strokeWidth =
              trackHeight // 선 두께
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, y), Offset(right, y), base);

    final segPaint =
        Paint()
          ..color = segmentColor
          ..strokeWidth = trackHeight
          ..strokeCap = StrokeCap.round;
    final clean = _normalizeIntervals(unfocused, start, end);

    for (final it in clean) {
      canvas.drawLine(
        Offset(toX(it.start), y),
        Offset(toX(it.end), y),
        segPaint,
      );
    }

    void drawDot(Offset c, Color fill, {Color? stroke, double? sw}) {
      final p = Paint()..color = fill;
      canvas.drawCircle(c, radius, p);
      if (stroke != null && (sw ?? 0) > 0) {
        final s =
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = sw!
              ..color = stroke;
        canvas.drawCircle(c, radius, s);
      }
    }

    drawDot(Offset(left, y), endpointColor);
    drawDot(Offset(right, y), endpointColor);

    final smallR = radius * 0.7;

    // 마커 목록: 엔드포인트는 라벨 표시, 집중X 경계는 showUnfocusedLabels에 따름
    final markers = <_Marker>[
      _Marker(toX(start), start, isEndpoint: true, showLabel: true),
      _Marker(toX(end), end, isEndpoint: true, showLabel: true),
      for (final it in clean)
        _Marker(toX(it.start), it.start, showLabel: showUnfocusedLabels),
      for (final it in clean)
        _Marker(toX(it.end), it.end, showLabel: showUnfocusedLabels),
    ]..sort((a, b) => a.x.compareTo(b.x));

    for (final m in markers) {
      if (!m.isEndpoint) {
        final fill = Paint()..color = markerFill;
        final border =
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2
              ..color = markerBorder;
        canvas.drawCircle(Offset(m.x, y), smallR, fill);
        canvas.drawCircle(Offset(m.x, y), smallR, border);
      }
      if (m.showLabel) {
        _drawLabel(
          canvas,
          Offset(m.x, labelY + (isResult ? 0 : 8)),
          _fmt(m.time),
        );
      }
    }
  }

  // 겹치거나 범위 밖 구간 정리
  List<TimeInterval> _normalizeIntervals(
    List<TimeInterval> list,
    DateTime s,
    DateTime e,
  ) {
    final filtered =
        list
            .map((it) {
              var a = it.start.isBefore(s) ? s : it.start;
              var b = it.end.isAfter(e) ? e : it.end;
              if (b.isBefore(a)) return null;
              return TimeInterval(a, b);
            })
            .whereType<TimeInterval>()
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));

    final merged = <TimeInterval>[];
    for (final it in filtered) {
      if (merged.isEmpty) {
        merged.add(it);
      } else {
        final last = merged.last;
        if (!it.start.isAfter(last.end)) {
          // 겹치면 병합
          merged[merged.length - 1] = TimeInterval(
            last.start,
            it.end.isAfter(last.end) ? it.end : last.end,
          );
        } else {
          merged.add(it);
        }
      }
    }
    return merged;
  }

  void _drawLabel(Canvas canvas, Offset centerBottom, String text) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = centerBottom - Offset(tp.width / 2, tp.height / 2);
    canvas.drawParagraph; // no-op; just to avoid lint in some editors
    tp.paint(canvas, offset);
  }

  // 집중 안함 마커
  String _fmt(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';
  // String _fmt(DateTime t) =>
  //     '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  bool shouldRepaint(covariant _FocusTimelinePainter old) =>
      old.start != start ||
      old.end != end ||
      old.unfocused != unfocused ||
      old.trackHeight != trackHeight ||
      old.radius != radius ||
      old.padding != padding ||
      old.baseColor != baseColor ||
      old.segmentColor != segmentColor ||
      old.endpointColor != endpointColor ||
      old.markerFill != markerFill ||
      old.markerBorder != markerBorder;
}

class _Marker {
  final double x;
  final DateTime time;
  final bool isEndpoint;
  final bool showLabel;
  _Marker(this.x, this.time, {this.isEndpoint = false, this.showLabel = false});
}
