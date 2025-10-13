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
  // SLEEP(졸음) 구간 추가
  final List<TimeInterval> sleep;
  final double height;
  final double trackHeight;
  final double radius;
  final EdgeInsets padding;
  final Color baseColor;
  final Color segmentColor;
  // SLEEP 색상
  final Color sleepColor;
  final Color endpointColor;
  final Color markerFill;
  final Color sleepMarkerFill;
  final Color markerBorder;
  final bool isResult;

  // NEW: 집중X 구간 라벨 표시 여부
  final bool showUnfocusedLabels;
  // SLEEP 라벨 표시 여부
  final bool showSleepLabels;

  const FocusTimelineBar({
    super.key,
    required this.start,
    required this.end,
    this.unfocused = const [],
    this.sleep = const [],
    this.height = 88,
    this.trackHeight = 2,
    this.radius = 5,
    this.padding = const EdgeInsets.fromLTRB(5, 15, 5, 14),
    this.baseColor = const Color(0xFF6BAB93), // 전체 라인
    this.segmentColor = const Color(0xFFF95C3B), // 집중X 구간
    this.endpointColor = const Color(0xFF6BAB93), // 양끝 점
    this.markerFill = const Color(0xFFF95C3B), // 집중X 구간 경계

    this.sleepColor = const Color.fromARGB(255, 197, 196, 182), // SLEEP 기본 라벤더
    this.sleepMarkerFill = const Color(0xFFE6E5D3), // SLEEP 마커

    this.markerBorder = const Color(0xFFF95C3B),
    this.showUnfocusedLabels = false,
    this.showSleepLabels = false,
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
          sleep: sleep,
          trackHeight: trackHeight,
          radius: radius,
          padding: padding,
          baseColor: baseColor,
          segmentColor: segmentColor,
          sleepColor: sleepColor,
          endpointColor: endpointColor,
          markerFill: markerFill,
          sleepMarkerFill: sleepMarkerFill,
          markerBorder: markerBorder,
          showUnfocusedLabels: showUnfocusedLabels,
          showSleepLabels: showSleepLabels,
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
  final List<TimeInterval> sleep;
  final double trackHeight, radius;
  final EdgeInsets padding;
  final Color baseColor, segmentColor, endpointColor, markerFill, markerBorder;
  final Color sleepColor, sleepMarkerFill;
  final TextStyle? textStyle;
  final bool showUnfocusedLabels;
  final bool showSleepLabels;
  final bool isResult;

  _FocusTimelinePainter({
    required this.start,
    required this.end,
    required this.unfocused,
    required this.sleep,
    required this.trackHeight,
    required this.radius,
    required this.padding,
    required this.baseColor,
    required this.segmentColor,
    required this.sleepColor,
    required this.endpointColor,
    required this.markerFill,
    required this.sleepMarkerFill,
    required this.markerBorder,
    required this.textStyle,
    required this.showUnfocusedLabels,
    required this.showSleepLabels,
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
          ..strokeWidth = trackHeight
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, y), Offset(right, y), base);

    final segPaint =
        Paint()
          ..color = segmentColor
          ..strokeWidth = trackHeight
          ..strokeCap = StrokeCap.round;

    final sleepPaint =
        Paint()
          ..color = sleepColor
          ..strokeWidth = trackHeight
          ..strokeCap = StrokeCap.round;

    final clean = _normalizeIntervals(unfocused, start, end);
    final sleepClean = _normalizeIntervals(sleep, start, end);

    // 먼저 unfocused (집중X) 그리기
    for (final it in clean) {
      canvas.drawLine(
        Offset(toX(it.start), y),
        Offset(toX(it.end), y),
        segPaint,
      );
    }

    // SLEEP 구간 그리기 (색상 구분)
    for (final it in sleepClean) {
      canvas.drawLine(
        Offset(toX(it.start), y),
        Offset(toX(it.end), y),
        sleepPaint,
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
        _Marker(
          toX(it.start),
          it.start,
          type: 'unfocused',
          showLabel: showUnfocusedLabels,
        ),
      for (final it in clean)
        _Marker(
          toX(it.end),
          it.end,
          type: 'unfocused',
          showLabel: showUnfocusedLabels,
        ),
      // sleep 구간 경계 마커
      for (final it in sleepClean)
        _Marker(
          toX(it.start),
          it.start,
          type: 'sleep',
          showLabel: showSleepLabels,
        ),
      for (final it in sleepClean)
        _Marker(toX(it.end), it.end, type: 'sleep', showLabel: showSleepLabels),
    ]..sort((a, b) => a.x.compareTo(b.x));

    for (final m in markers) {
      if (!m.isEndpoint) {
        // 마커 타입별 색상 선택
        final fillColor = m.type == 'sleep' ? sleepMarkerFill : markerFill;
        final borderColor = m.type == 'sleep' ? sleepMarkerFill : markerBorder;
        final fill = Paint()..color = fillColor;
        final border =
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2
              ..color = borderColor;
        canvas.drawCircle(Offset(m.x, y), smallR, fill);
        canvas.drawCircle(Offset(m.x, y), smallR, border);
      }
      if (m.showLabel) {
        _drawLabel(
          canvas,
          Offset(m.x, labelY + (isResult ? 17 : 0)),
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
      old.sleep != sleep ||
      old.trackHeight != trackHeight ||
      old.radius != radius ||
      old.padding != padding ||
      old.baseColor != baseColor ||
      old.segmentColor != segmentColor ||
      old.sleepColor != sleepColor ||
      old.endpointColor != endpointColor ||
      old.markerFill != markerFill ||
      old.sleepMarkerFill != sleepMarkerFill ||
      old.markerBorder != markerBorder;
}

class _Marker {
  final double x;
  final DateTime time;
  final bool isEndpoint;
  final bool showLabel;
  final String type; // 'unfocused', 'sleep', ''
  _Marker(
    this.x,
    this.time, {
    this.isEndpoint = false,
    this.showLabel = false,
    this.type = '',
  });
}
