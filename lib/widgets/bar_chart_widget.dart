import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarChartWidget extends StatelessWidget {
  final List<num> values; // 길이 24 가정
  const BarChartWidget({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    final List<StudyData> chartData = List.generate(24, (i) {
      final v = i < values.length ? values[i].toDouble() : 0.0;
      return StudyData('$i', v);
    });

    return SfCartesianChart(
      plotAreaBorderWidth: 0, // 사각형 테두리 제거
      title: ChartTitle(
        text: '누적 집중 시간 / 시간대',
        textStyle: TextStyle(
          fontFamily: 'SoyoMaple',
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      primaryXAxis: const CategoryAxis(
        title: AxisTitle(text: '시간대', textStyle: TextStyle(fontSize: 10)),
        majorGridLines: MajorGridLines(width: 0), // X축 주 격자 제거
        axisLine: AxisLine(width: 0), // X축 선 제거
        interval: 1,
        labelStyle: TextStyle(fontSize: 9),
      ),
      primaryYAxis: const NumericAxis(
        majorGridLines: MajorGridLines(width: 1), // Y축 주 격자 제거

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

class StudyData {
  final String hours;
  final double studytime;

  StudyData(this.hours, this.studytime);
}
