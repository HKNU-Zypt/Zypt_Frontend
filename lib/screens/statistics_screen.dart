import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:focused_study_time_tracker/models/focus_time.dart';
import 'package:focused_study_time_tracker/services/focus_time_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late DateTime _currentMonth; // 월 네비게이션용 (1일 고정)
  late DateTime _selectedDay; // 선택된 날짜
  List<FocusTimeResponseDto> _items = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _fetchForSelectedDay();
  }

  Future<void> _fetchForSelectedDay() async {
    setState(() {
      _loading = true;
      _error = null;
      _items = [];
    });
    try {
      final list = await FocusTimeService().getFocusTimes(
        year: _selectedDay.year,
        month: _selectedDay.month,
        day: _selectedDay.day,
      );
      setState(() => _items = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goPrevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _goNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthHeader(),
              const SizedBox(height: 8),
              _buildCalendar(),
              const SizedBox(height: 16),
              if (_loading) const LinearProgressIndicator(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (!_loading && _error == null)
                Expanded(
                  child:
                      _items.isEmpty
                          ? const Center(child: Text('기록이 없습니다'))
                          : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 16),
                            itemBuilder:
                                (context, index) =>
                                    FocusTimeline(item: _items[index]),
                          ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    final title = DateFormat('MMMM yyyy').format(_currentMonth);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _goPrevMonth,
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _goNextMonth,
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = _currentMonth;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0: Sun ... 6: Sat
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    final days = <DateTime>[];
    // 앞쪽 비우기 (이전달 일부)
    for (int i = 0; i < firstWeekday; i++) {
      days.add(firstDayOfMonth.subtract(Duration(days: firstWeekday - i)));
    }
    // 이번달
    for (int d = 0; d < daysInMonth; d++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, d + 1));
    }
    // 6주 그리드를 채우도록 뒤를 채움
    while (days.length % 7 != 0) {
      days.add(days.last.add(const Duration(days: 1)));
    }

    final weekLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              weekLabels
                  .map(
                    (w) => Expanded(
                      child: Center(
                        child: Text(
                          w,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.2,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final isThisMonth = day.month == _currentMonth.month;
            final isSelected =
                day.year == _selectedDay.year &&
                day.month == _selectedDay.month &&
                day.day == _selectedDay.day;
            return GestureDetector(
              onTap:
                  isThisMonth
                      ? () {
                        setState(
                          () =>
                              _selectedDay = DateTime(
                                day.year,
                                day.month,
                                day.day,
                              ),
                        );
                        _fetchForSelectedDay();
                      }
                      : null,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF1E88E5)
                            : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color:
                          isThisMonth
                              ? (isSelected ? Colors.white : Colors.black87)
                              : Colors.grey,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class FocusTimeline extends StatelessWidget {
  final FocusTimeResponseDto item;
  const FocusTimeline({super.key, required this.item});

  int _toSeconds(String hhmmss) {
    final parts = hhmmss.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final s = int.parse(parts[2]);
    return h * 3600 + m * 60 + s;
  }

  @override
  Widget build(BuildContext context) {
    final startSec = _toSeconds(item.startAt);
    final endSec = _toSeconds(item.endAt);
    final totalSec = (endSec - startSec).clamp(1, 24 * 60 * 60);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.startAt),
              Text('조각 ${item.unFocusedTimeDtos.length}'),
              Text(item.endAt),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  // 베이스 라인 (집중 구간)
                  Container(
                    height: 8,
                    width: width,
                    decoration: BoxDecoration(
                      color: const Color(0xFF64B5F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // 비집중 구간 덮어쓰기 (초 단위, 최소 폭 보장)
                  ...item.unFocusedTimeDtos.map((u) {
                    final uStart = _toSeconds(
                      u.startAt,
                    ).clamp(startSec, endSec);
                    final uEnd = _toSeconds(u.endAt).clamp(startSec, endSec);
                    final uDur = (uEnd - uStart).clamp(0, totalSec);
                    if (uDur <= 0) return const SizedBox.shrink();
                    final left = (uStart - startSec) / totalSec * width;
                    double w = uDur / totalSec * width;
                    if (w < 2) w = 2; // 아주 짧은 구간도 보이도록 최소 폭 보장
                    final color =
                        u.type == UnFocusedType.SLEEP
                            ? const Color(0xFFF57C00) // 진한 주황(졸음)
                            : const Color(0xFFFFEB3B); // 선명한 노랑(산만)
                    return Positioned(
                      left: left,
                      top: 0,
                      child: Container(
                        height: 8,
                        width: w,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black26, width: 0.5),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
