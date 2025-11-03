import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/box_design.dart';
import 'package:focused_study_time_tracker/components/focus_line_bar.dart';
import 'package:focused_study_time_tracker/components/statsCard.dart';
import 'package:focused_study_time_tracker/models/focus_time.dart';
import 'package:focused_study_time_tracker/services/focus_time_service.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

DateTime now = DateTime.now();

// HH:mm 형식의 문자열을 오늘 날짜의 DateTime 객체로 변환하는 함수
DateTime _onToday(String hhmm) {
  final p = hhmm.split(':');
  return DateTime(
    now.year,
    now.month,
    now.day,
    int.parse(p[0]),
    int.parse(p[1]),
    int.parse(p[2]),
  );
}

// 최대 집중 시간 계산
Duration getMaxFocusDuration(
  List<TimeInterval> unfocused,
  DateTime start,
  DateTime end,
) {
  // 집중 구간 리스트 만들기
  List<TimeInterval> focusIntervals = [];
  DateTime prev = start;
  for (final uf in unfocused) {
    if (uf.start.isAfter(prev)) {
      focusIntervals.add(TimeInterval(prev, uf.start));
    }
    prev = uf.end;
  }
  if (prev.isBefore(end)) {
    focusIntervals.add(TimeInterval(prev, end));
  }
  if (focusIntervals.isEmpty) {
    // unfocused가 없으면 전체가 집중 구간
    focusIntervals.add(TimeInterval(start, end));
  }
  // 가장 긴 집중 구간 찾기
  return focusIntervals
      .map((ti) => ti.end.difference(ti.start))
      .reduce((a, b) => a > b ? a : b);
}

// 집중 시간 계산
Duration getTotalFocusDuration(
  DateTime start,
  DateTime end,
  List<TimeInterval> unfocused,
) {
  final total = end.difference(start);
  final unfocusedSum = unfocused.fold<Duration>(
    Duration.zero,
    (prev, uf) => prev + uf.end.difference(uf.start),
  );
  return total - unfocusedSum;
}

// 시간 포맷 함수
String formatDuration(Duration d) {
  if (d.inHours > 0) {
    return '${d.inHours}시간 ${d.inMinutes % 60}분';
  } else {
    return '${d.inMinutes}분';
  }
}

class _RecordListScreenState extends State<RecordListScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  //  달별 데이터 캐시 추가
  static final Map<String, List<FocusTimeResponseDto>> _monthCache = {};

  List<FocusTimeResponseDto> _monthData = []; // 해당 달 전체 데이터
  List<FocusTimeResponseDto> _selectedDayData = []; // 선택한 날 데이터

  // 캐시 키 함수
  String _monthKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();

    // 오늘 날짜 기준
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(today.year, today.month, 1);

    // 오늘이 현재 달이면 오늘 선택, 아니면 1일 선택
    _focusedDay = today;
    _selectedDay =
        (today.month == _focusedDay.month && today.year == _focusedDay.year)
            ? today
            : firstDayOfMonth;

    _fetchMonthData(_focusedDay);
  }

  // 달 데이터 조회
  Future<void> _fetchMonthData(DateTime day) async {
    final key = _monthKey(day);
    if (_monthCache.containsKey(key)) {
      setState(() {
        _monthData = _monthCache[key]!;
      });
      _filterSelectedDayData(_selectedDay ?? day);
      return;
    }
    try {
      final data = await FocusTimeService().getFocusTimes(
        year: day.year,
        month: day.month,
      );
      setState(() {
        _monthData = data;
        _monthCache[key] = data; // 캐시에 저장
      });
      _filterSelectedDayData(_selectedDay ?? day);
    } catch (e) {
      _monthData = [];
      _monthCache[key] = [];
      print('달 데이터 조회 실패: $e');
    }
  }

  // 선택한 날짜의 데이터만 필터링
  void _filterSelectedDayData(DateTime day) {
    setState(() {
      _selectedDayData =
          _monthData.where((e) {
            final date = DateTime.parse(e.createDate);
            return date.day == day.day;
          }).toList();
    });
  }

  bool _hasFocusDataFor(DateTime day) {
    // 예: _focusDataList가 집중이 있었던 날짜들의 리스트라면
    return _selectedDayData.any(
      (data) => isSameDay(DateTime.parse(data.createDate), day),
    );
  }

  // 공통: 해당 day에 데이터 있는지
  bool _hasDataForDay(DateTime day) {
    // 둘 다 로컬 기준으로 비교 (서버 createDate는 Z 없으면 로컬로 파싱됨)
    final localDay = day.toLocal();
    return _monthData.any((e) {
      final d = DateTime.parse(e.createDate).toLocal();
      return d.year == localDay.year &&
          d.month == localDay.month &&
          d.day == localDay.day;
    });
  }

  // 공통: 셀 UI 빌더
  Widget _buildDayCell(
    DateTime day, {
    required bool isSelected,
    required bool isToday,
  }) {
    final bool hasData = _hasDataForDay(day);
    final bool isOutside = day.month != _focusedDay.month;

    // 배경 색 (네 현재 스타일 유지)
    Color bg =
        isSelected
            ? const Color(0xFF407362)
            : isOutside
            ? const Color(0xff798B85)
            : const Color(0xffACC9BF);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        // 데이터 있는 날에만 테두리
        border:
            hasData
                ? Border.all(color: const Color(0xFF407362), width: 2)
                : null,
      ),
      child: Center(
        child: Text('${day.day}', style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            OffsetOutlinedCard(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TableCalendar(
                daysOfWeekHeight: 20,
                rowHeight: 47,
                locale: 'en_US',
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),

                onDaySelected: (selectedDay, focusedDay) {
                  // 이전/다음 달 날짜 클릭 방지
                  if (selectedDay.month != _focusedDay.month) return;
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _filterSelectedDayData(selectedDay); // ← 이 줄 추가!
                },
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _filterSelectedDayData(_selectedDay!); // 1일 데이터로 필터링
                  _fetchMonthData(focusedDay); // ← 달이 바뀔 때마다 해당 달 데이터 조회
                },

                headerStyle: HeaderStyle(
                  titleCentered: true,
                  titleTextFormatter:
                      (date, locale) => DateFormat.yMMMM(locale).format(date),
                  titleTextStyle: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                  formatButtonVisible: false,
                  leftChevronIcon: const Icon(
                    Icons.arrow_left_outlined,
                    color: Color(0xFFD9D9D9),
                    size: 40,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.arrow_right_outlined,
                    color: Color(0xFFD9D9D9),
                    size: 40,
                  ),
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0xffACC9BF),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(color: Colors.black),
                  weekendDecoration: BoxDecoration(
                    color: Color(0xffACC9BF),
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.black),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF407362),
                    shape: BoxShape.circle,
                  ),
                  defaultDecoration: BoxDecoration(
                    color: Color(0xffACC9BF),
                    shape: BoxShape.circle,
                  ),
                  outsideDecoration: BoxDecoration(
                    color: Color(0xff798B85),
                    shape: BoxShape.circle,
                  ),
                  outsideTextStyle: TextStyle(color: Colors.white),
                  selectedTextStyle: TextStyle(color: Colors.black),
                  cellMargin: EdgeInsets.zero,
                  cellPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _FocusData(selectedDayData: _selectedDayData),

            const SizedBox(height: 20),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class RecordResult extends StatelessWidget {
  const RecordResult({super.key});

  @override
  Widget build(BuildContext context) {
    return OffsetOutlinedCard(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽 라벨들 (세로)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "최대 집중 시간 :",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'AppleSDGothicNeo',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "최소 집중 시간 :",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'AppleSDGothicNeo',
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "하루 평균 집중 시간 :",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'AppleSDGothicNeo',
                        ),
                      ),
                    ],
                  ),
                ),
                // 오른쪽 값들 (세로)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "14시",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'AppleSDGothicNeo',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "09시",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'AppleSDGothicNeo',
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "10시간 30분",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'AppleSDGothicNeo',
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
          Divider(thickness: 1.2, color: Colors.black87, height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: 5),
                Text(
                  "ㅇㅇ님은 총 ㅇㅇㅇㅇ시간 집중했어요!",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'AppleSDGothicNeo',
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusData extends StatelessWidget {
  const _FocusData({
    super.key,
    required List<FocusTimeResponseDto> selectedDayData,
  }) : _selectedDayData = selectedDayData;

  final List<FocusTimeResponseDto> _selectedDayData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          _selectedDayData.isEmpty
              ? []
              : _selectedDayData.map((focusData) {
                final startTime = focusData.startAt; // 'HH:mm'
                final endTime = focusData.endAt; // 'HH:mm'

                final startDt = _onToday(startTime);
                final endDt = _onToday(endTime);

                final startTimeForStudyTime = startTime.substring(0, 5);
                final endTimeForStudyTime = endTime.substring(0, 5);

                // unfocused 구간 변환
                final unfocused =
                    focusData.unFocusedTimeDtos
                        .where((dto) => dto.type == UnFocusedType.DISTRACTED)
                        .map(
                          (dto) => TimeInterval(
                            _onToday(dto.startAt),
                            _onToday(dto.endAt),
                          ),
                        )
                        .toList();

                final sleepIntervals =
                    focusData.unFocusedTimeDtos
                        .where((dto) => dto.type == UnFocusedType.SLEEP)
                        .map(
                          (dto) => TimeInterval(
                            _onToday(dto.startAt),
                            _onToday(dto.endAt),
                          ),
                        )
                        .toList();

                // 전체 구간, 집중 구간 미리 계산
                final totalDuration = endDt.difference(startDt);
                final focusedDuration = getTotalFocusDuration(
                  startDt,
                  endDt,
                  unfocused,
                );

                // 최대 집중 시간 계산
                final maxFocusDuration = getMaxFocusDuration(
                  unfocused,
                  startDt,
                  endDt,
                );
                final maxFocusStr = formatDuration(maxFocusDuration);

                // 총 집중 시간
                final totalFocusStr = formatDuration(focusedDuration);

                // 집중 비율 계산
                final percent =
                    totalDuration.inSeconds == 0
                        ? 0
                        : (focusedDuration.inSeconds /
                                totalDuration.inSeconds *
                                100)
                            .round();
                final percentStr = '$percent%';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: OffsetOutlinedCard(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              focusData.createDate,
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xffF95C3B),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'AppleSDGothicNeo',
                              ),
                            ),

                            PopupMenuButton<String>(
                              child: Image.asset(
                                'assets/images/more_icon.png',
                                width: 14,
                                height: 15,
                              ),
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('삭제'),
                                    ),
                                  ],
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  await FocusTimeService().deleteFocusTimes(
                                    focusData.id,
                                  );
                                  // 삭제 성공 후 화면 데이터에서 직접 제거
                                  if (context.mounted) {
                                    final state =
                                        context
                                            .findAncestorStateOfType<
                                              _RecordListScreenState
                                            >();
                                    if (state != null) {
                                      state.setState(() {
                                        state._selectedDayData.remove(
                                          focusData,
                                        );
                                        state._monthData.remove(focusData);
                                      });
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        FocusTimelineBar(
                          start: _onToday(startTime),
                          end: _onToday(endTime),
                          unfocused: unfocused, // ← 동적으로 생성된 unfocused 리스트
                          sleep: sleepIntervals,
                          height: 25,
                          isResult: true,
                        ),
                        SizedBox(height: 15),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 공부 시간
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        "공부 시간",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'AppleSDGothicNeo',
                                        ),
                                      ),
                                      SizedBox(width: 7),
                                      Flexible(
                                        child: Text(
                                          "$startTimeForStudyTime - $endTimeForStudyTime",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'AppleSDGothicNeo',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 최대 집중 시간
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "최대 집중 시간",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'AppleSDGothicNeo',
                                        ),
                                      ),
                                      SizedBox(width: 7),
                                      Flexible(
                                        child: Text(
                                          maxFocusStr,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'AppleSDGothicNeo',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 집중 시간
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        "집중 시간",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          totalFocusStr,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'AppleSDGothicNeo',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 평균 집중 비율
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "평균 집중 비율",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'AppleSDGothicNeo',
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        percentStr,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'AppleSDGothicNeo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
    );
  }
}

// 점(Point)을 표현하는 위젯
class _TimePoint extends StatelessWidget {
  final Color color;
  final String text;

  const _TimePoint({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      height: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(fontSize: 5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// 선(Line)을 표현하는 위젯
class _TimeLine extends StatelessWidget {
  final Color color;
  final int flex; // flex 값을 받을 수 있도록 추가

  const _TimeLine({required this.color, this.flex = 1}); // 기본값은 1

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex, // 전달받은 flex 값 적용
      child: SizedBox(
        height: 40,
        child: Column(
          children: [SizedBox(height: 9.5), Container(height: 3, color: color)],
        ),
      ),
    );
  }
}
