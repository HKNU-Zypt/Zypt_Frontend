import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:focused_study_time_tracker/screens/record_list_screen.dart';
import 'package:focused_study_time_tracker/screens/statistics_all_screen.dart';
import 'package:go_router/go_router.dart';

class StatisticsScreenv2 extends StatefulWidget {
  const StatisticsScreenv2({super.key});

  @override
  State<StatisticsScreenv2> createState() => _StatisticsScreenv2State();
}

class _StatisticsScreenv2State extends State<StatisticsScreenv2> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    StatisticsAllScreen(), // 차트, 통계 요약 등
    RecordListScreen(), // 기록 리스트 위젯
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text(
          "통계",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'SoyoMaple',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 버튼 고정 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  fixedSize: Size(125, 10),
                  side: BorderSide(
                    color:
                        _selectedIndex == 0 ? Colors.black : Colors.transparent,
                  ),
                  backgroundColor:
                      _selectedIndex == 1 ? Colors.white : Color(0xff6BAD97),
                ),
                onPressed: () => setState(() => _selectedIndex = 0),
                child: Text(
                  "전체 통계",
                  style: TextStyle(
                    color: Colors.black, // 텍스트 색상 변경
                    fontFamily: 'SoyoMaple',
                    fontWeight:
                        _selectedIndex == 1
                            ? FontWeight.normal
                            : FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 50),
              TextButton(
                style: TextButton.styleFrom(
                  fixedSize: Size(125, 10),
                  side: BorderSide(
                    color:
                        _selectedIndex == 1 ? Colors.black : Colors.transparent,
                  ),
                  backgroundColor:
                      _selectedIndex == 1 ? Color(0xff6BAD97) : Colors.white,
                ),
                onPressed: () => setState(() => _selectedIndex = 1),
                child: Text(
                  "기록 리스트",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'SoyoMaple',
                    fontWeight:
                        _selectedIndex == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          // 본문 화면 스크롤 영역
          Expanded(
            child: SingleChildScrollView(child: _screens[_selectedIndex]),
          ),
        ],
      ),
    );
  }
}
