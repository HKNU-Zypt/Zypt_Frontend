import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/screens/statistics_all_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 시간 대에 따른 값
    final List<StudyData> chartData = [
      StudyData('0', 87),
      StudyData('1', 65),
      StudyData('2', 38),
      StudyData('3', 18),
      StudyData('4', 7),
      StudyData('5', 8),
      StudyData('6', 5),
      StudyData('7', 20),
      StudyData('8', 13),
      StudyData('9', 43),
      StudyData('10', 56),
      StudyData('11', 55),
      StudyData('12', 22),
      StudyData('13', 41),
      StudyData('14', 60),
      StudyData('15', 83),
      StudyData('16', 89),
      StudyData('17', 49),
      StudyData('18', 23),
      StudyData('19', 20),
      StudyData('20', 71),
      StudyData('21', 82),
      StudyData('22', 100),
      StudyData('23', 115),
    ];

    return SfCartesianChart(
      plotAreaBorderWidth: 0, // 사각형 테두리 제거

      primaryXAxis: const CategoryAxis(
        title: AxisTitle(text: '시간대', textStyle: TextStyle(fontSize: 10)),
        majorGridLines: MajorGridLines(width: 0), // X축 주 격자 제거
        axisLine: AxisLine(width: 0), // X축 선 제거
      ),
      primaryYAxis: const NumericAxis(
        title: AxisTitle(text: '누적 집중 시간', textStyle: TextStyle(fontSize: 10)),
        majorGridLines: MajorGridLines(width: 0), // Y축 주 격자 제거
        axisLine: AxisLine(width: 0), // Y축 선 제거
      ),
      series: <CartesianSeries<StudyData, String>>[
        ColumnSeries<StudyData, String>(
          dataSource: chartData,
          xValueMapper: (StudyData times, _) => times.hours,
          yValueMapper: (StudyData times, _) => times.studytime,
          dataLabelSettings: const DataLabelSettings(
            isVisible: false,
            labelPosition: ChartDataLabelPosition.outside,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ), // 막대 둥글게 만들기
        ),
      ],
    );
  }
}
