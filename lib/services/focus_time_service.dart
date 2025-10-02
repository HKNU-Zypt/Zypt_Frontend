import 'dart:convert';

import 'package:focused_study_time_tracker/const.dart';
import 'package:focused_study_time_tracker/models/focus_time.dart';
import 'package:focused_study_time_tracker/services/login.dart';
import 'package:http/http.dart' as http;

class FocusTimeService {
  static final FocusTimeService _instance = FocusTimeService._internal();
  factory FocusTimeService() => _instance;
  FocusTimeService._internal();

  final LoginService _loginService = LoginService();

  Future<Map<String, String>> _authHeaders() async {
    return await _loginService.getAuthHeaders();
  }

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('http://$baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query.map((k, v) => MapEntry(k, '$v')));
  }

  void _validateDateQuery({int? year, int? month, int? day}) {
    final hasYear = year != null;
    final hasMonth = month != null;
    final hasDay = day != null;

    final isValid =
        (hasYear && !hasMonth && !hasDay) ||
        (hasYear && hasMonth && !hasDay) ||
        (hasYear && hasMonth && hasDay);

    if (!(isValid || (!hasYear && !hasMonth && !hasDay))) {
      throw ArgumentError(
        '잘못된 쿼리 조합입니다. 허용: year | year+month | year+month+day',
      );
    }
  }

  /// POST /api/focus_times
  Future<String> createFocusTime(FocusTimeInsertDto dto) async {
    final uri = _buildUri('/api/focus_times');

    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _authHeaders();
        return http.post(uri, headers: headers, body: jsonEncode(dto.toJson()));
      },
    );
    if (response.statusCode == 200) {
      return response.body; // "저장 성공"
    }
    throw _toException(response);
  }

  /// GET /api/focus_times?year&month&day
  Future<List<FocusTimeResponseDto>> getFocusTimes({
    int? year,
    int? month,
    int? day,
  }) async {
    _validateDateQuery(year: year, month: month, day: day);
    final query = <String, dynamic>{};
    if (year != null) query['year'] = year;
    if (month != null) query['month'] = month;
    if (day != null) query['day'] = day;

    final uri = _buildUri('/api/focus_times', query);

    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _authHeaders();
        return http.get(uri, headers: headers);
      },
    );
    if (response.statusCode == 200) {
      return _parseListResponse(response.body);
    }
    throw _toException(response);
  }

  /// GET /api/focus_times/all
  Future<List<FocusTimeResponseDto>> getAllFocusTimes() async {
    final uri = _buildUri('/api/focus_times/all');

    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _authHeaders();
        return http.get(uri, headers: headers);
      },
    );
    if (response.statusCode == 200) {
      return _parseListResponse(response.body);
    }
    throw _toException(response);
  }

  /// DELETE /api/focus_times?year&month&day
  Future<String> deleteFocusTimesByDate({
    int? year,
    int? month,
    int? day,
  }) async {
    _validateDateQuery(year: year, month: month, day: day);
    final query = <String, dynamic>{};
    if (year != null) query['year'] = year;
    if (month != null) query['month'] = month;
    if (day != null) query['day'] = day;

    final uri = _buildUri('/api/focus_times/date', query);

    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _authHeaders();
        return http.delete(uri, headers: headers);
      },
    );
    if (response.statusCode == 200) {
      return response.body; // "집중 데이터 삭제 완료"
    }
    throw _toException(response);
  }

  /// DELETE /api/focus_times?year&month&day
  Future<String> deleteFocusTimes(int id) async {
    final query = <String, dynamic>{};
    query['focusId'] = id;

    final uri = _buildUri('/api/focus_times', query);

    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _authHeaders();
        return http.delete(uri, headers: headers);
      },
    );
    if (response.statusCode == 200) {
      return response.body; // "집중 데이터 삭제 완료"
    }
    throw _toException(response);
  }

  FocusTimeApiException _toException(http.Response response) {
    try {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final err = ApiErrorResponse.fromJson(jsonBody);
      return FocusTimeApiException(error: err, statusCode: response.statusCode);
    } catch (_) {
      return FocusTimeApiException(
        error: ApiErrorResponse(
          code: -1,
          message: '알 수 없는 오류',
          detail: response.body.isNotEmpty ? response.body : null,
        ),
        statusCode: response.statusCode,
      );
    }
  }

  List<FocusTimeResponseDto> _parseListResponse(String body) {
    try {
      final trimmed = body.trim();
      if (trimmed.isEmpty || trimmed == 'null') {
        return <FocusTimeResponseDto>[];
      }

      final dynamic decoded = jsonDecode(trimmed);
      if (decoded is List) {
        return decoded
            .map(
              (e) => FocusTimeResponseDto.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      if (decoded is Map<String, dynamic>) {
        // 단일 객체가 내려온 경우도 방어적으로 처리
        return [FocusTimeResponseDto.fromJson(decoded)];
      }

      throw FormatException('예상치 못한 응답 타입: ${decoded.runtimeType}');
    } catch (e) {
      throw FocusTimeApiException(
        error: ApiErrorResponse(
          code: -1,
          message: '응답 파싱 실패',
          detail: e.toString(),
        ),
        statusCode: 200,
      );
    }
  }
}

extension FocusTimeStatisticsApi on FocusTimeService {
  /// GET /api/focus_times/statistics?from=yyyy-MM-dd&to=yyyy-MM-dd
  Future<FocusTimeStatisticsResponseDto> getStatistics({
    required DateTime from,
    required DateTime to,
  }) async {
    final query = <String, dynamic>{
      'from': _formatDate(from),
      'to': _formatDate(to),
    };
    final uri = _buildUri('/api/focus_times/statistics', query);

    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _loginService.getAuthHeaders();
        return http.get(uri, headers: headers);
      },
    );
    if (response.statusCode == 200) {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      return FocusTimeStatisticsResponseDto.fromJson(map);
    }
    throw _toException(response);
  }

  String _formatDate(DateTime d) {
    // yyyy-MM-dd
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
