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
    // 예시 데이터
    final stats = {
      '공부 시간': '1시간',
      '집중 시간': '55분',
      '집중하지 못한 시간': '5분',
      '졸음': '1번',
      '집중하지 않음': '0번',
    };

    // 집중 시작~끝 시간 예시
    final times = ['11:30', '14:45'];
    final unfocusTime = ['11:40', '11:45', '12:30', '13:40'];

    // HH:mm 형식의 문자열을 오늘 날짜의 DateTime 객체로 변환하는 함수
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

    // 집중하지 못한 구간 예시 , HH:mm 형식의 문자열 리스트
    final unfocused = [
      TimeInterval(
        _onToday(unfocusTime[0]),
        _onToday(unfocusTime[1]),
      ), // 11:40~11:45
      TimeInterval(
        _onToday(unfocusTime[2]),
        _onToday(unfocusTime[3]),
      ), // 12:30~13:40
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16),
            Text(
              '집중 분석 결과',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'SoyoMaple',
              ),
            ),
            SizedBox(height: 8),
            Text(
              "${now.year}.${now.month}.${now.day} (${weekdays[now.weekday - 1]})",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'AppleSDGothicNeo',
              ),
            ),
            SizedBox(height: 32),
            OffsetOutlinedCard(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: FocusTimelineBar(
                start: startDt, // 시작 시간
                end: endDt, // 끝 시간
                unfocused: unfocused, // 집중하지 못한 구간 리스트
                height: 45, // 전체 높이
              ),
            ),
            SizedBox(height: 20),
            OffsetOutlinedCard(
              padding: const EdgeInsets.fromLTRB(60, 16, 60, 16),
              child: Column(
                children:
                    stats.entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  e.key,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'AppleSDGothicNeo',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  e.value,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'AppleSDGothicNeo',
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
