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
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${DateFormat('yyyy.M.d').format(startDate)} ~ ${DateFormat('yyyy.M.d').format(endDate)}",
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
                        color: Color(0xFF757575),
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
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_right_outlined,
                        color: Color(0xFF757575),
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

                    // --- ✨ 1. 현재 월이 선택된 날짜의 월인지 확인하는 로직 ---
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
                      // --- ✨ 2. isSelectedMonth 값에 따라 동적으로 스타일 적용 ---
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration:
                            isSelectedMonth
                                ? BoxDecoration(
                                  color: Color(0xFF121212), // 선택된 월 배경색
                                  shape: BoxShape.circle,
                                )
                                : null, // 선택되지 않았으면 아무 스타일 없음
                        child: Text(
                          DateFormat('MMM').format(DateTime(0, month)),
                          style: TextStyle(
                            color:
                                isSelectedMonth ? Colors.white : Colors.black,
                            fontSize: 10, // 선택 여부에 따른 글자색
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
                      color: const Color(0xFFD9D9D9),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.calendar_month_outlined, size: 20),
                            onPressed: () {
                              setState(() {
                                // ✨ 1. 피커를 열기 전에, 현재 선택 모드에 따라 focusedDay를 설정합니다.
                                if (isSelectingStartDate) {
                                  // '시작 날짜' 선택 모드이면, focusedDay를 startDate로 설정
                                  focusedDay = localStartDate;
                                } else {
                                  // '종료 날짜' 선택 모드이면, focusedDay를 endDate로 설정
                                  focusedDay = localEndDate;
                                }
                                // ✨ 2. 뷰를 전환합니다.
                                isShowingPicker = !isShowingPicker;
                              });
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelectingStartDate = true;
                                // ✨ 1. focusedDay를 startDate로 설정하여 캘린더 뷰를 이동시킵니다.
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
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelectingStartDate = false;
                                // ✨ 2. focusedDay를 endDate로 설정하여 캘린더 뷰를 이동시킵니다.
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
                  if (isShowingPicker)
                    buildYearMonthPicker()
                  else
                    TableCalendar(
                      focusedDay: focusedDay,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      // ✨ 1. onRangeSelected 대신 onDaySelected를 다시 사용합니다.
                      onDaySelected: (selectedDay, newFocusedDay) {
                        setState(() {
                          if (isSelectingStartDate) {
                            localStartDate = selectedDay;
                            // 시작 날짜가 기존 종료 날짜보다 뒤에 있는지 확인
                            if (localEndDate.isBefore(localStartDate)) {
                              // 뒤에 있을 경우 종료 날짜를 시작 날짜와 같게 맞춰줌
                              localEndDate = localStartDate;
                            }
                            // 종료일 선택 모드로 전환
                            isSelectingStartDate = false;
                            // ✨ 1. focusedDay를 newFocusedDay(클릭된 날짜)가 아닌,
                            // ✨    기존의 localEndDate로 설정하여 뷰를 이동시킵니다.
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
                      // ✨ 2. selectedDayPredicate를 사용하여 두 날짜를 개별적으로 선택 표시합니다.
                      selectedDayPredicate: (day) {
                        return isSameDay(localStartDate, day) ||
                            isSameDay(localEndDate, day);
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        leftChevronIcon: Icon(
                          Icons.arrow_left_outlined,
                          color: Color(0xFF757575),
                          size: 40,
                        ),
                        rightChevronIcon: Icon(
                          Icons.arrow_right_outlined,
                          color: Color(0xFF757575),
                          size: 40,
                        ),
                      ),
                      // ✨ 3. range 관련 스타일을 제거하고 selectedDecoration만 사용합니다.
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.transparent,
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
