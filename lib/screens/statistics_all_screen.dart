import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/widgets/bar_chart_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class StatisticsAllScreen extends StatefulWidget {
  const StatisticsAllScreen({super.key});

  @override
  State<StatisticsAllScreen> createState() => _StatisticsAllScreenState();
}

class _StatisticsAllScreenState extends State<StatisticsAllScreen> {
  void showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          // 다이얼로그의 모서리를 둥글게 만듭니다.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 콘텐츠 크기에 맞게 크기 조절
              children: [
                // 확인 및 닫기 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                // 캘린더 헤더 (월 이동 버튼 등)
                TableCalendar(
                  focusedDay: DateTime.now(),
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    // 선택된 날짜의 디자인을 커스텀합니다.
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  // 날짜를 눌렀을 때의 동작
                  onDaySelected: (selectedDay, focusedDay) {
                    // 여기에 날짜 선택 로직을 구현합니다.
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("2025.1.1~2025.9.6"),
              IconButton(
                onPressed: () => {showCalendarDialog(context)},
                icon: Icon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black),
              color: Colors.white,
            ),
            child: BarChartWidget(),
          ),
          SizedBox(height: 30),
          Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black),
            ),
            child: Column(
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
