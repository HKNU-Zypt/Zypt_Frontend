import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/box_design.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // 초기 선택일을 오늘로 설정
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          BoxDesign(
            backgroundcolor: Colors.white,
            designcolor: Color(0xFFD9D9D9),
            width: 300,
            height: 270,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: TableCalendar(
                    locale: 'en_US',
                    // 상태 변수를 사용
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),

                    // ✨ 2. 날짜 선택 기능을 다시 활성화
                    onDaySelected: (selectedDay, focusedDay) {
                      // setState를 호출하여 화면을 새로고침
                      setState(() {
                        _selectedDay = selectedDay;
                        // ✨ focusedDay도 함께 업데이트하여 캘린더 뷰를 이동시킴
                        _focusedDay = focusedDay;
                      });
                    },

                    // ✨ 3. selectedDayPredicate가 상태 변수를 바라보도록 수정
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                    // 사용자가 페이지를 스와이프했을 때 focusedDay를 업데이트
                    onPageChanged: (focusedDay) {
                      // ✨ setState를 호출하여 화면을 새로고침하도록 변경
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },

                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      titleTextFormatter:
                          (date, locale) =>
                              DateFormat.yMMMM(locale).format(date),
                      titleTextStyle: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      formatButtonVisible: false,
                      // ✨ 4. 화살표를 다시 보이도록 설정 (기본값이 true라 사실 이 줄들은 생략 가능)
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

                    // ✨ 3. range 관련 스타일을 제거하고 selectedDecoration만 사용합니다.
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
              ),
            ),
          ),
          const SizedBox(height: 20),
          BoxDesign(
            backgroundcolor: Colors.white,
            designcolor: Color(0xFFD9D9D9),
            width: 300,
            height: 120,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                        ),
                      ),
                      Icon(Icons.more_horiz_outlined, size: 15),
                    ],
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: 284,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        children: [
                          _TimePoint(color: Colors.grey, text: "09:30"),
                          _TimeLine(color: Colors.grey, flex: 2),

                          _TimePoint(color: Color(0xFFE0E0E0), text: "11:40"),
                          _TimeLine(color: Color(0xFFE0E0E0), flex: 1),

                          _TimePoint(color: Color(0xFFE0E0E0), text: "13:25"),
                          _TimeLine(color: Colors.grey, flex: 3),

                          _TimePoint(color: Color(0xFFE0E0E0), text: "16:25"),
                          _TimeLine(color: Color(0xFFE0E0E0), flex: 3),

                          _TimePoint(color: Color(0xFFE0E0E0), text: "19:50"),
                          _TimeLine(color: Colors.grey, flex: 3),

                          _TimePoint(color: Color(0xFFE0E0E0), text: "20:14"),
                          _TimeLine(color: Color(0xFFE0E0E0), flex: 3),

                          _TimePoint(color: Color(0xFFE0E0E0), text: "21:47"),
                          _TimeLine(color: Colors.grey, flex: 2),

                          _TimePoint(color: Colors.grey, text: "22:30"),
                        ],
                      ),
                    ),
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
                              SizedBox(width: 10),
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
                              SizedBox(width: 10),
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
                              SizedBox(width: 10),
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
          ),
          const SizedBox(height: 20),
          BoxDesign(
            backgroundcolor: Colors.white,
            designcolor: Color(0xFFD9D9D9),
            width: 300,
            height: 170,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("최대 집중 시간대 : 23시"),
                Text("최소 집중 시간대 : 6시"),
                SizedBox(height: 15),
                Text("하루 평균 집중 시간 : 10시간"),
                SizedBox(height: 15),
                Text("- - - - - - - - - - - - - - - - - - - - - - - -"),
                SizedBox(height: 15),
                Text("ㅇㅇ님은 총 ㅇㅇㅇㅇ시간 집중했어요!"),
              ],
            ),
          ),
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
