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
      appBar: AppBar(title: Text("통계"), centerTitle: true),
      body: Column(
        children: [
          // 버튼 고정 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedIndex == 0 ? Colors.blue : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedIndex = 0),
                child: Text("전체 통계"),
              ),
              SizedBox(width: 75),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedIndex == 1 ? Colors.blue : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedIndex = 1),
                child: Text("기록 리스트"),
              ),
            ],
          ),

          // 본문 화면 전환
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
