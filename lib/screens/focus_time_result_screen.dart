import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/statsCard.dart';
import 'package:focused_study_time_tracker/components/focus_line_bar.dart';

class FocusResultScreen extends StatelessWidget {
  FocusResultScreen({super.key});

  DateTime now = DateTime.now();
  var weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final stats = {
      '공부 시간': '1시간',
      '집중 시간': '55분',
      '집중하지 못한 시간': '5분',
      '졸음': '1번',
      '집중하지 않음': '0번',
    };

    final times = ['11:30', '11:40', '11:45', '12:30', '13:40', '14:45'];

    DateTime _onToday(String hhmm) {
      final p = hhmm.split(':');
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(p[0]),
        int.parse(p[1]),
      );
    }

    final startDt = _onToday(times.first);
    final endDt = _onToday(times.last);
    final unfocused = [
      TimeInterval(_onToday(times[1]), _onToday(times[2])), // 11:40~11:45
      TimeInterval(_onToday(times[3]), _onToday(times[4])), // 11:40~11:45
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16),
            Text(
              '집중 분석 결과',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "${now.year}.${now.month}.${now.day} (${weekdays[now.weekday - 1]})",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            OffsetOutlinedCard(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: FocusTimelineBar(
                start: startDt,
                end: endDt,
                unfocused: unfocused,
                height: 45,
                trackHeight: 3,
              ),
            ),
            SizedBox(height: 20), // 이부분에 적용해야해
            OffsetOutlinedCard(
              child: Column(
                children:
                    stats.entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key, style: TextStyle(fontSize: 18)),
                                Text(
                                  e.value,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
