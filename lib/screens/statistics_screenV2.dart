import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/screens/record_list_screen.dart';
import 'package:focused_study_time_tracker/screens/statistics_all_screen.dart';

class StatisticsScreenv2 extends StatefulWidget {
  const StatisticsScreenv2({super.key});

  @override
  State<StatisticsScreenv2> createState() => _StatisticsScreenv2State();
}

class _StatisticsScreenv2State extends State<StatisticsScreenv2>
    with AutomaticKeepAliveClientMixin<StatisticsScreenv2> {
  static int _lastSelectedTabIndex = 0;
  int _selectedIndex = _lastSelectedTabIndex;

  final List<Widget> _screens = [
    StatisticsAllScreen(), // 차트, 통계 요약 등
    RecordListScreen(), // 기록 리스트 위젯
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                onPressed:
                    () => setState(() {
                      _selectedIndex = 0;
                      _lastSelectedTabIndex = _selectedIndex;
                    }),
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
                onPressed:
                    () => setState(() {
                      _selectedIndex = 1;
                      _lastSelectedTabIndex = _selectedIndex;
                    }),
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
          // 본문 화면: 두 탭 위젯을 모두 유지하여 상태 보존
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children:
                  _screens.map((w) => SingleChildScrollView(child: w)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
