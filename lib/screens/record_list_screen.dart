import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/box_design.dart';
import 'package:focused_study_time_tracker/components/focus_line_bar.dart';
import 'package:focused_study_time_tracker/components/statsCard.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

DateTime now = DateTime.now();

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

class _RecordListScreenState extends State<RecordListScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // 집중 시작~끝 시간 예시

  final startDt = _onToday(times.first);
  final endDt = _onToday(times.last);
  // unfocused 구간을 동적으로 생성
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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          OffsetOutlinedCard(
            child: TableCalendar(
              locale: 'en_US',
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),

              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },

              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextFormatter:
                    (date, locale) => DateFormat.yMMMM(locale).format(date),
                titleTextStyle: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
                formatButtonVisible: false,
                leftChevronIcon: Icon(
                  Icons.arrow_left_outlined,
                  color: Color(0xFFD9D9D9),
                  size: 40,
                ),
                rightChevronIcon: Icon(
                  Icons.arrow_right_outlined,
                  color: Color(0xFFD9D9D9),
                  size: 40,
                ),
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: Colors.black),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF121212),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          OffsetOutlinedCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy.M.d').format(_selectedDay!),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'AppleSDGothicNeo',
                      ),
                    ),
                    Icon(Icons.more_horiz_outlined, size: 15),
                  ],
                ),
                SizedBox(height: 5),
                FocusTimelineBar(
                  start: startDt, // 시작 시간
                  end: endDt, // 끝 시간
                  unfocused: unfocused, // 집중하지 못한 구간 리스트
                  height: 45, // 전체 높이
                  trackHeight: 3, // 집중 바 높이
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("공부 시간", style: TextStyle(fontSize: 10)),
                            SizedBox(width: 5),
                            Text(
                              "9:30 - 22:30 (2시간)",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Row(
                          children: [
                            Text("최대 집중 시간", style: TextStyle(fontSize: 10)),
                            SizedBox(width: 5),
                            Text(
                              "00분",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("집중 시간", style: TextStyle(fontSize: 10)),
                            SizedBox(width: 5),
                            Text(
                              "00시간 00분",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 55),
                        Row(
                          children: [
                            Text("평균 집중 비율", style: TextStyle(fontSize: 10)),
                            SizedBox(width: 10),
                            Text(
                              "00%",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OffsetOutlinedCard(
            padding: const EdgeInsets.fromLTRB(60, 16, 60, 16),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("최대 집중 시간대 :"), Text(" 14시")],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("최소 집중 시간대 :"), Text(" 09시")],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("하루 평균 집중 시간 :"), Text(" 10시간")],
                ),

                SizedBox(height: 15),
                Divider(thickness: 1.2, color: Colors.black87, height: 32),
                SizedBox(height: 15),
                Text("ㅇㅇ님은 총 ㅇㅇㅇㅇ시간 집중했어요!"),
              ],
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

// 점(Point)을 표현하는 위젯
class _TimePoint extends StatelessWidget {
  final Color color;
  final String text;

  const _TimePoint({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      height: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(fontSize: 5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// 선(Line)을 표현하는 위젯
class _TimeLine extends StatelessWidget {
  final Color color;
  final int flex; // flex 값을 받을 수 있도록 추가

  const _TimeLine({required this.color, this.flex = 1}); // 기본값은 1

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex, // 전달받은 flex 값 적용
      child: SizedBox(
        height: 40,
        child: Column(
          children: [SizedBox(height: 9.5), Container(height: 3, color: color)],
        ),
      ),
    );
  }
}
