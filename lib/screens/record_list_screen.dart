import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Stack(
            children: [
              Positioned(
                child: Transform.translate(
                  offset: Offset(5, 5),
                  child: Container(
                    width: 300,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ),
              ),
              Container(
                width: 300,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black),
                  boxShadow: [BoxShadow(color: Colors.grey)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 400,
                      height: 350,
                      child: TableCalendar(
                        locale: 'en_US',
                        // ✨ 1. focusedDay를 오늘로 고정
                        focusedDay: DateTime.now(),
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        // ✨ 2. 날짜 선택 기능을 비활성화
                        onDaySelected: (selectedDay, focusedDay) {
                          // 아무것도 하지 않음
                        },
                        // ✨ 3. 어떤 날짜도 '선택된' 상태가 아니도록 설정
                        selectedDayPredicate: (day) => false,
                        // 헤더 스타일링 (이전과 동일)
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
                          leftChevronVisible: false,
                          rightChevronVisible: false,
                        ),

                        // ✨ 4. 오늘 날짜만 특별하게 디자인
                        calendarBuilders: CalendarBuilders(
                          // 오늘 날짜(today) UI
                          todayBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              decoration: const BoxDecoration(
                                color: Colors.black, // 오늘 날짜 배경색
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ), // 오늘 날짜 글자색
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Positioned(
                child: Transform.translate(
                  offset: Offset(5, 5),
                  child: Container(
                    width: 300,
                    height: 125,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ),
              ),
              Container(
                width: 300,
                height: 125,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('yyyy.M.d').format(DateTime.now()),
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
                        child: Column(
                          children: [
                            Container(
                              width: 284,
                              height: 25,
                              decoration: BoxDecoration(color: Colors.white),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: Row(
                                  children: [
                                    // 시작 점
                                    _TimePoint(color: Colors.grey),
                                    // 어두운 선
                                    _TimeLine(color: Colors.grey, flex: 2),
                                    // 밝은 점
                                    _TimePoint(color: Color(0xFFE0E0E0)),
                                    _TimeLine(
                                      color: Color(0xFFE0E0E0),
                                      flex: 1,
                                    ),
                                    _TimePoint(color: Color(0xFFE0E0E0)),
                                    _TimeLine(color: Colors.grey, flex: 3),
                                    _TimePoint(color: Color(0xFFE0E0E0)),
                                    _TimeLine(
                                      color: Color(0xFFE0E0E0),
                                      flex: 3,
                                    ),
                                    _TimePoint(color: Color(0xFFE0E0E0)),
                                    _TimeLine(color: Colors.grey, flex: 3),
                                    _TimePoint(color: Color(0xFFE0E0E0)),
                                    _TimeLine(
                                      color: Color(0xFFE0E0E0),
                                      flex: 3,
                                    ),
                                    _TimePoint(color: Color(0xFFE0E0E0)),
                                    _TimeLine(color: Colors.grey, flex: 2),
                                    // ... 이런 식으로 패턴을 반복 ...
                                    // 끝 점
                                    _TimePoint(color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 284,
                              height: 15,
                              decoration: BoxDecoration(color: Colors.white),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(text: "09:30"),
                                    _TimeLine(
                                      color: Colors.transparent,
                                      flex: 2,
                                    ),
                                    CustomText(text: "11:40"),
                                    _TimeLine(
                                      color: Colors.transparent,
                                      flex: 1,
                                    ),
                                    CustomText(text: "13:25"),
                                    _TimeLine(
                                      color: Colors.transparent,
                                      flex: 3,
                                    ),
                                    CustomText(text: "16:25"),
                                    _TimeLine(
                                      color: Colors.transparent,
                                      flex: 3,
                                    ),
                                    CustomText(text: "19:50"),
                                    _TimeLine(
                                      color: Colors.transparent,
                                      flex: 3,
                                    ),
                                    CustomText(text: "20:14"),
                                    _TimeLine(
                                      color: Colors.transparent,
                                      flex: 3,
                                    ),
                                    CustomText(text: "21:47"),
                                    _TimeLine(
                                      color: Colors.transparent,
                                      flex: 2,
                                    ),
                                    CustomText(text: "22:30"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
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
                                  Text(
                                    "최대 집중 시간",
                                    style: TextStyle(fontSize: 10),
                                  ),
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
                                  Text(
                                    "평균 집중 비율",
                                    style: TextStyle(fontSize: 10),
                                  ),
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
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Positioned(
                child: Transform.translate(
                  offset: Offset(5, 5),
                  child: Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black),
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("최대 집중 시간대 : 23시"),
                    Text("최소 집중 시간대 : 6시"),
                    SizedBox(height: 20),
                    Text("하루 평균 집중 시간 : 10시간"),
                    SizedBox(height: 20),
                    Text("- - - - - - - - - - - - - - - - - - - - - - - -"),
                    SizedBox(height: 20),
                    Text("ㅇㅇ님은 총 ㅇㅇㅇㅇ시간 집중했어요!"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 점(Point)을 표현하는 위젯
class _TimePoint extends StatelessWidget {
  final Color color;
  const _TimePoint({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
      child: Container(height: 3, color: color),
    );
  }
}

// 텍스트 사이즈를 정해놓은 위젯
class CustomText extends StatelessWidget {
  // 위젯이 받을 속성들을 선언합니다.
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  // 생성자: required 키워드로 text와 fontSize를 필수값으로 지정
  const CustomText({
    super.key,
    required this.text,
    this.fontSize = 7,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    // Text 위젯을 반환합니다.
    return Text(
      text, // 전달받은 text
      style: TextStyle(
        fontSize: fontSize, // 전달받은 fontSize
        fontWeight: fontWeight,
      ),
    );
  }
}
