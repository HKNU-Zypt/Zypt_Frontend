import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/models/focus_time.dart';
import 'package:focused_study_time_tracker/services/focus_time_service.dart';

class FocusTimeTestScreen extends StatefulWidget {
  const FocusTimeTestScreen({super.key});

  @override
  State<FocusTimeTestScreen> createState() => _FocusTimeTestScreenState();
}

class _FocusTimeTestScreenState extends State<FocusTimeTestScreen> {
  final _yearCtrl = TextEditingController(text: '2025');
  final _monthCtrl = TextEditingController(text: '8');
  final _dayCtrl = TextEditingController(text: '9');
  final _startCtrl = TextEditingController(text: '09:00:00');
  final _endCtrl = TextEditingController(text: '12:00:00');
  final _dateCtrl = TextEditingController(text: '2025-08-09');

  final _logs = <String>[];
  bool _loading = false;

  void _log(String msg) {
    setState(() {
      _logs.insert(0, msg);
    });
  }

  Future<void> _create() async {
    setState(() => _loading = true);
    try {
      final dto = FocusTimeInsertDto(
        startAt: _startCtrl.text.trim(),
        endAt: _endCtrl.text.trim(),
        createDate: _dateCtrl.text.trim(),
        fragmentedUnFocusedTimeInsertDtos: [
          FragmentedUnFocusedTimeInsertDto(
            startAt: '10:15:00',
            endAt: '10:25:00',
            type: UnFocusedType.DISTRACTED,
          ),
        ],
      );
      final msg = await FocusTimeService().createFocusTime(dto);
      _log('POST 성공: $msg');
    } catch (e) {
      _log('POST 실패: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _get() async {
    setState(() => _loading = true);
    try {
      final year = _yearCtrl.text.isEmpty ? null : int.tryParse(_yearCtrl.text);
      final month =
          _monthCtrl.text.isEmpty ? null : int.tryParse(_monthCtrl.text);
      final day = _dayCtrl.text.isEmpty ? null : int.tryParse(_dayCtrl.text);
      final list = await FocusTimeService().getFocusTimes(
        year: year,
        month: month,
        day: day,
      );
      _log(
        'GET 성공: ${jsonEncode(list.map((e) => {'id': e.id, 'memberId': e.memberId, 'createDate': e.createDate, 'startAt': e.startAt, 'endAt': e.endAt, 'unCount': e.unFocusedTimeDtos.length}).toList())}',
      );
    } catch (e) {
      _log('GET 실패: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _getAll() async {
    setState(() => _loading = true);
    try {
      final list = await FocusTimeService().getAllFocusTimes();
      _log('GET /all 성공: ${list.length}건');
    } catch (e) {
      _log('GET /all 실패: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _loading = true);
    try {
      final year = _yearCtrl.text.isEmpty ? null : int.tryParse(_yearCtrl.text);
      final month =
          _monthCtrl.text.isEmpty ? null : int.tryParse(_monthCtrl.text);
      final day = _dayCtrl.text.isEmpty ? null : int.tryParse(_dayCtrl.text);
      final msg = await FocusTimeService().deleteFocusTimesByDate(
        year: year,
        month: month,
        day: day,
      );
      _log('DELETE 성공: $msg');
    } catch (e) {
      _log('DELETE 실패: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FocusTime 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startCtrl,
                    decoration: const InputDecoration(
                      labelText: 'startAt HH:mm:ss',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _endCtrl,
                    decoration: const InputDecoration(
                      labelText: 'endAt HH:mm:ss',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateCtrl,
              decoration: const InputDecoration(
                labelText: 'createDate YYYY-MM-DD',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearCtrl,
                    decoration: const InputDecoration(labelText: 'year (옵션)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _monthCtrl,
                    decoration: const InputDecoration(labelText: 'month (옵션)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _dayCtrl,
                    decoration: const InputDecoration(labelText: 'day (옵션)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _create,
                  child: const Text('POST 생성'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _get,
                  child: const Text('GET 조회'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _getAll,
                  child: const Text('GET 전체'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _delete,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('DELETE 삭제'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            const Text('로그'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) => Text(_logs[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
