import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/box_design.dart';
import 'package:focused_study_time_tracker/components/statsCard.dart';
import 'package:focused_study_time_tracker/widgets/bar_chart_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class StatisticsAllScreen extends StatefulWidget {
  const StatisticsAllScreen({super.key});

  @override
  State<StatisticsAllScreen> createState() => _StatisticsAllScreenState();
}

class _StatisticsAllScreenState extends State<StatisticsAllScreen> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 16), // ← 원하는 만큼 조절 (예: 16)
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${DateFormat('yyyy.M.d').format(startDate)} ~ ${DateFormat('yyyy.M.d').format(endDate)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'AppleSDGothicNeo-Bold',
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final selectedDates = await showCalendarDialog(
                      context,
                      initialStartDate: startDate,
                      initialEndDate: endDate,
                    );

                    if (selectedDates != null) {
                      setState(() {
                        startDate = selectedDates['startDate']!;
                        endDate = selectedDates['endDate']!;
                      });
                    }
                  },
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            child: OffsetOutlinedCard(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: BarChartWidget(),
            ),
          ),
          const SizedBox(height: 30),
          OffsetOutlinedCard(
            padding: const EdgeInsets.fromLTRB(60, 16, 60, 16),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("최대 집중 시간대 : "), Text("23시")],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [Text("최소 집중 시간대 : "), Text("6시")],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("하루 평균 집중 시간 : "), Text("10시")],
                ),
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

Future<Map<String, DateTime>?> showCalendarDialog(
  BuildContext context, {
  required DateTime initialStartDate,
  required DateTime initialEndDate,
}) async {
  return await showDialog<Map<String, DateTime>>(
    context: context,
    builder: (BuildContext context) {
      DateTime localStartDate = initialStartDate;
      DateTime localEndDate = initialEndDate;
      DateTime focusedDay = initialStartDate;
      bool isShowingPicker = false;
      bool isSelectingStartDate = true;

      return StatefulBuilder(
        builder: (context, setState) {
          Widget buildYearMonthPicker() {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_left_outlined,
                        color: Color(0xFFF95C3B),
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          focusedDay = DateTime(
                            focusedDay.year - 1,
                            focusedDay.month,
                          );
                        });
                      },
                    ),
                    Text(
                      DateFormat('yyyy').format(focusedDay),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'AppleSDGothicNeo-Bold',
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_right_outlined,
                        color: Color(0xFFF95C3B),
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          focusedDay = DateTime(
                            focusedDay.year + 1,
                            focusedDay.month,
                          );
                        });
                      },
                    ),
                  ],
                ),
                Divider(),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;

                    bool isSelectedMonth = false;
                    // '시작 날짜' 선택 모드일 때
                    if (isSelectingStartDate) {
                      if (focusedDay.year == localStartDate.year &&
                          month == localStartDate.month) {
                        isSelectedMonth = true;
                      }
                    }
                    // '종료 날짜' 선택 모드일 때
                    else {
                      if (focusedDay.year == localEndDate.year &&
                          month == localEndDate.month) {
                        isSelectedMonth = true;
                      }
                    }

                    return TextButton(
                      onPressed: () {
                        setState(() {
                          focusedDay = DateTime(focusedDay.year, month);
                          isShowingPicker = false;

                          // 연/월 피커에서 월을 선택했을 때도 날짜 자동 조정 로직 추가
                          if (isSelectingStartDate) {
                            localStartDate = focusedDay;
                            if (localEndDate.isBefore(localStartDate)) {
                              localEndDate = localStartDate;
                            }
                          } else {
                            if (focusedDay.isBefore(localStartDate)) {
                              localStartDate = focusedDay;
                              localEndDate = focusedDay;
                            } else {
                              localEndDate = focusedDay;
                            }
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration:
                            isSelectedMonth
                                ? BoxDecoration(
                                  color: Color(0xFF407362),
                                  shape: BoxShape.circle,
                                )
                                : null,
                        child: Text(
                          DateFormat('MMM').format(DateTime(0, month)),
                          style: TextStyle(
                            color:
                                isSelectedMonth ? Colors.white : Colors.black,
                            fontSize: 17,
                            fontFamily: 'AppleSDGothicNeo-Bold',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            // '저장' 시 선택된 날짜들을 Map에 담아 반환
                            Navigator.of(context).pop({
                              'startDate': localStartDate,
                              'endDate': localEndDate,
                            });
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
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            // '닫기' 시 null을 반환하며 닫힘
                            Navigator.of(context).pop();
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
                      border: Border.all(color: Color(0xFF121212), width: 1.4),
                      color: const Color(0xFF6BAB93),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.calendar_month_outlined,
                              size: 25,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                if (isSelectingStartDate) {
                                  focusedDay = localStartDate;
                                } else {
                                  focusedDay = localEndDate;
                                }
                                isShowingPicker = !isShowingPicker;
                              });
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelectingStartDate = true;
                                focusedDay = localStartDate;
                              });
                            },
                            child: Text(
                              DateFormat('MMM d, yyyy').format(localStartDate),
                              style: TextStyle(
                                color:
                                    isSelectingStartDate
                                        ? Color(0xFF121212)
                                        : Color(0xFF757575),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'AppleSDGothicNeo-Bold',
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelectingStartDate = false;
                                focusedDay = localEndDate;
                              });
                            },
                            child: Text(
                              DateFormat('MMM d, yyyy').format(localEndDate),
                              style: TextStyle(
                                color:
                                    !isSelectingStartDate
                                        ? Color(0xFF121212)
                                        : Color(0xFF757575),
                                fontFamily: 'AppleSDGothicNeo-Bold',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (isShowingPicker)
                    buildYearMonthPicker()
                  else
                    TableCalendar(
                      focusedDay: focusedDay,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      onDaySelected: (selectedDay, newFocusedDay) {
                        setState(() {
                          if (isSelectingStartDate) {
                            localStartDate = selectedDay;
                            if (localEndDate.isBefore(localStartDate)) {
                              localEndDate = localStartDate;
                            }
                            // 종료일 선택 모드로 전환
                            isSelectingStartDate = false;
                            focusedDay = localEndDate;
                          } else {
                            // 종료 날짜 선택 로직은 기존과 동일
                            if (!selectedDay.isBefore(localStartDate)) {
                              localEndDate = selectedDay;
                            }
                            // 종료일 선택 시에는 클릭한 곳으로 포커스 이동
                            focusedDay = newFocusedDay;
                          }
                        });
                      },
                      onPageChanged: (newFocusedDay) {
                        setState(() {
                          focusedDay = newFocusedDay;
                        });
                      },
                      selectedDayPredicate: (day) {
                        return isSameDay(localStartDate, day) ||
                            isSameDay(localEndDate, day);
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AppleSDGothicNeo-Bold',
                        ),
                        leftChevronIcon: Icon(
                          Icons.arrow_left_outlined,
                          color: Color(0xFFF95C3B),
                          size: 40,
                        ),
                        rightChevronIcon: Icon(
                          Icons.arrow_right_outlined,
                          color: Color(0xFFF95C3B),
                          size: 40,
                        ),
                      ),
                      // 1. 요일 스타일 설정
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        // 평일 (월~금) 스타일
                        weekdayStyle: TextStyle(
                          fontFamily: 'AppleSDGothicNeo-Medium', // <-- 폰트 적용
                          color: Colors.black,
                        ),
                        // 주말 (토~일) 스타일
                        weekendStyle: TextStyle(
                          fontFamily: 'AppleSDGothicNeo-Medium', // <-- 폰트 적용
                          color: Colors.black,
                        ),
                      ),
                      calendarStyle: const CalendarStyle(
                        // 기본 날짜 스타일 (가장 중요)
                        defaultTextStyle: TextStyle(
                          fontFamily: 'AppleSDGothicNeo-Medium', // <-- 폰트 적용
                        ),

                        // 주말 날짜 스타일
                        weekendTextStyle: TextStyle(
                          fontFamily: 'AppleSDGothicNeo-Medium', // <-- 폰트 적용
                          color: Colors.black, // 주말은 보통 빨간색으로 표시
                        ),

                        // 다른 달의 날짜 스타일
                        outsideTextStyle: TextStyle(
                          fontFamily: 'AppleSDGGothicNeo-Medium', // <-- 폰트 적용
                          color: Colors.black,
                        ),

                        todayDecoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: Colors.black,
                          fontFamily: 'AppleSDGothicNeo-Medium', // <-- 폰트 적용
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFF407362),
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: TextStyle(
                          color: Colors.white,
                          fontFamily: 'AppleSDGothicNeo-Medium', // <-- 폰트 적용
                        ),
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
