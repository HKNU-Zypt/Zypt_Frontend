import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/widgets/bar_chart_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class StatisticsAllScreen extends StatefulWidget {
  const StatisticsAllScreen({super.key});

  @override
  State<StatisticsAllScreen> createState() => _StatisticsAllScreenState();
}

class _StatisticsAllScreenState extends State<StatisticsAllScreen> {
  // 캘린더 dialog
  void showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 상태 변수들을 StatefulBuilder 바깥에 선언
        DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
        DateTime endDate = DateTime.now();
        // ✨ 1. '선택 모드'를 기억할 변수 추가 (초기값은 '시작 날짜 선택 모드')
        bool isSelectingStartDate = true;
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              // 다이얼로그의 배경색과 모서리를 설정합니다.
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 콘텐츠 크기에 맞게 다이얼로그 크기 조절
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: const Color(0xFF121212),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () {
                              print("저장 버튼 클릭");
                            },
                            icon: Icon(
                              Icons.check_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Color(0xFF121212),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () {
                              print("닫기 버튼 클릭");
                            },
                            icon: Icon(
                              Icons.close_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Color(0xFF121212),
                          width: 1.4,
                        ),
                        color: Colors.grey,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.calendar_month_outlined, size: 20),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isSelectingStartDate = true;
                                });
                              },
                              style: TextButton.styleFrom(
                                // 현재 선택 모드에 따라 배경색으로 시각적 힌트 제공
                                backgroundColor: Colors.transparent,
                              ),
                              child: Text(
                                DateFormat('MMM d, yyyy').format(startDate),
                                style: TextStyle(
                                  color:
                                      isSelectingStartDate
                                          ? Color(0xFF121212)
                                          : const Color.fromARGB(
                                            255,
                                            186,
                                            186,
                                            186,
                                          ),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isSelectingStartDate = false;
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              ),
                              child: Text(
                                DateFormat('MMM d, yyyy').format(endDate),
                                style: TextStyle(
                                  color:
                                      !isSelectingStartDate
                                          ? Color(0xFF121212)
                                          : const Color.fromARGB(
                                            255,
                                            186,
                                            186,
                                            186,
                                          ),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // 캘린더 위젯
                    TableCalendar(
                      focusedDay: isSelectingStartDate ? startDate : endDate,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          if (isSelectingStartDate) {
                            startDate = selectedDay;
                          } else {
                            // 종료일이 시작일보다 빠르지 않도록 간단한 유효성 검사 추가 (선택사항)
                            if (!selectedDay.isBefore(startDate)) {
                              endDate = selectedDay;
                            }
                          }
                        });
                      },
                      // ✨ 4. 두 날짜 모두 달력에 표시되도록 수정
                      selectedDayPredicate: (day) {
                        return isSameDay(startDate, day) ||
                            isSameDay(endDate, day);
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,

                        leftChevronIcon: Icon(
                          Icons.arrow_left_outlined,
                          color: Colors.grey, // 색상 변경
                          size: 40,
                          // 크기 변경
                        ),
                        // 오른쪽 화살표 아이콘을 원하는 모양으로 변경
                        rightChevronIcon: Icon(
                          Icons.arrow_right_outlined,
                          color: Colors.grey,
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("2025.1.1 - 2025.9.6"),
              IconButton(
                onPressed: () {
                  showCalendarDialog(context);
                },
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black),
              color: Colors.white,
            ),
            child: const BarChartWidget(),
          ),
          const SizedBox(height: 30),
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
    );
  }
}
