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
                "${DateFormat('yyyy.M.d').format(startDate)} - ${DateFormat('yyyy.M.d').format(endDate)}",
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
      bool isSelectingStartDate = true;

      return StatefulBuilder(
        builder: (context, setState) {
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
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 20),
                          TextButton(
                            onPressed:
                                () =>
                                    setState(() => isSelectingStartDate = true),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                            ),
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
                            onPressed:
                                () => setState(
                                  () => isSelectingStartDate = false,
                                ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                            ),
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
                  TableCalendar(
                    focusedDay:
                        (isSelectingStartDate ? localStartDate : localEndDate),
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        if (isSelectingStartDate) {
                          localStartDate = selectedDay;
                          isSelectingStartDate = false;
                        } else {
                          if (!selectedDay.isBefore(localStartDate)) {
                            localEndDate = selectedDay;
                          }
                        }
                      });
                    },
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
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(color: Colors.transparent),
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
