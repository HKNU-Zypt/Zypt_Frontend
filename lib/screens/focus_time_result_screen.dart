import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:focused_study_time_tracker/components/statsCard.dart';
import 'package:focused_study_time_tracker/components/focus_line_bar.dart';
import 'package:focused_study_time_tracker/models/focus_time.dart'; // DTO 모델 import

// 1. 생성자를 통해 FocusTimeInsertDto 데이터를 전달받도록 수정합니다.
class FocusResultScreen extends StatelessWidget {
  final FocusTimeInsertDto sessionData;

  FocusResultScreen({super.key, required this.sessionData});

  // 2. 예시 데이터를 모두 삭제합니다.
  final DateTime now = DateTime.now();
  final weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  // 날짜와 시간(HH:mm:ss) 문자열을 DateTime 객체로 변환하는 헬퍼 함수
  DateTime parseDateTime(String date, String time) {
    return DateTime.parse('$date $time');
  }

  @override
  Widget build(BuildContext context) {
    // 3. 전달받은 sessionData를 사용해 UI에 필요한 값들을 즉시 계산합니다.
    final sessionStart = parseDateTime(
      sessionData.createDate,
      sessionData.startAt,
    );
    final sessionEnd = parseDateTime(sessionData.createDate, sessionData.endAt);
    final totalStudyDuration = sessionEnd.difference(sessionStart);

    Duration totalUnfocusedDuration = Duration.zero;
    int sleepCount = 0;
    int distractedCount = 0;
    final List<TimeInterval> distractedIntervals = [];
    final List<TimeInterval> sleepIntervals = [];

    for (var u in sessionData.fragmentedUnFocusedTimeInsertDtos) {
      final start = parseDateTime(sessionData.createDate, u.startAt);
      final end = parseDateTime(sessionData.createDate, u.endAt);
      final dur = end.difference(start);
      totalUnfocusedDuration += dur;

      if (u.type == UnFocusedType.SLEEP) {
        sleepCount++;
        sleepIntervals.add(TimeInterval(start, end));
      } else {
        distractedCount++;
        distractedIntervals.add(TimeInterval(start, end));
      }
    }

    final totalFocusedDuration = totalStudyDuration - totalUnfocusedDuration;

    final stats = {
      '공부 시간': '${totalStudyDuration.inMinutes}분',
      '집중 시간': '${totalFocusedDuration.inMinutes}분',
      '집중하지 못한 시간': '${totalUnfocusedDuration.inMinutes}분',
      '졸음': '$sleepCount번',
      '집중하지 않음': '$distractedCount번',
    };

    // 4. 계산된 값을 사용하여 UI를 구성합니다.
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  start: sessionStart,
                  end: sessionEnd,
                  unfocused: distractedIntervals,
                  sleep: sleepIntervals,
                  height: 45,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: SizedBox(
                  width: 320,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      side: BorderSide(color: Colors.black, width: 1),
                    ),
                    onPressed: () {
                      context.go('/home');
                    },
                    child: Center(
                      child: Text(
                        '홈으로 이동',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SoyoMaple',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
