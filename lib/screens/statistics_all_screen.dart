import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/widgets/bar_chart_widget.dart';

class StatisticsAllScreen extends StatefulWidget {
  const StatisticsAllScreen({super.key});

  @override
  State<StatisticsAllScreen> createState() => _StatisticsAllScreenState();
}

class StudyData {
  final String hours;
  final double studytime;

  StudyData(this.hours, this.studytime);
}

class _StatisticsAllScreenState extends State<StatisticsAllScreen> {
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
                onPressed: () => {print("달력 클릭")},
                icon: Icon(Icons.edit_outlined),
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
                Text("최대 집중 시간대 : "),
                Text("최소 집중 시간대 : "),
                SizedBox(height: 20),
                Text("하루 평균 집중 시간 : "),
                SizedBox(height: 20),
                Text("- - - - - - - - - - - - - - - - - -"),
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
