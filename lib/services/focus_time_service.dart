import 'dart:convert';

import 'package:focused_study_time_tracker/const.dart';
import 'package:focused_study_time_tracker/models/focus_time.dart';
import 'package:focused_study_time_tracker/services/login.dart';
import 'package:http/http.dart' as http;

class FocusTimeService {
  static final FocusTimeService _instance = FocusTimeService._internal();
  factory FocusTimeService() => _instance;
  FocusTimeService._internal();

  Future<Map<String, String>> _authHeaders({Map<String, String>? extra}) async {
    final access = await LoginService().getAccessToken();
    final headers = <String, String>{
      'Authorization': 'Bearer $access',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (extra != null) ...extra,
    };
    return headers;
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
    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode(dto.toJson()),
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
    final response = await http.get(uri, headers: await _authHeaders());
    if (response.statusCode == 200) {
      return _parseListResponse(response.body);
    }
    throw _toException(response);
  }

  /// GET /api/focus_times/all
  Future<List<FocusTimeResponseDto>> getAllFocusTimes() async {
    final uri = _buildUri('/api/focus_times/all');
    final response = await http.get(uri, headers: await _authHeaders());
    if (response.statusCode == 200) {
      return _parseListResponse(response.body);
    }
    throw _toException(response);
  }

  /// DELETE /api/focus_times?year&month&day
  Future<String> deleteFocusTimes({int? year, int? month, int? day}) async {
    _validateDateQuery(year: year, month: month, day: day);
    final query = <String, dynamic>{};
    if (year != null) query['year'] = year;
    if (month != null) query['month'] = month;
    if (day != null) query['day'] = day;

    final uri = _buildUri('/api/focus_times', query);
    final response = await http.delete(uri, headers: await _authHeaders());
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
