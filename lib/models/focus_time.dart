import 'dart:convert';

/// 비집중 타입
enum UnFocusedType { SLEEP, DISTRACTED }

UnFocusedType parseUnFocusedType(String value) {
  switch (value) {
    case 'SLEEP':
      return UnFocusedType.SLEEP;
    case 'DISTRACTED':
      return UnFocusedType.DISTRACTED;
    default:
      throw ArgumentError('Unknown UnFocusedType: $value');
  }
}

String unFocusedTypeToJson(UnFocusedType type) {
  switch (type) {
    case UnFocusedType.SLEEP:
      return 'SLEEP';
    case UnFocusedType.DISTRACTED:
      return 'DISTRACTED';
  }
}

/// POST 요청용 비집중 구간 조각 DTO
class FragmentedUnFocusedTimeInsertDto {
  final String startAt; // HH:mm:ss
  final String endAt; // HH:mm:ss
  final UnFocusedType type;

  FragmentedUnFocusedTimeInsertDto({
    required this.startAt,
    required this.endAt,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'startAt': startAt,
    'endAt': endAt,
    'type': unFocusedTypeToJson(type),
  };
}

/// POST 요청용 집중 구간 DTO
class FocusTimeInsertDto {
  final String startAt; // HH:mm:ss
  final String endAt; // HH:mm:ss
  final String createDate; // YYYY-MM-DD
  final List<FragmentedUnFocusedTimeInsertDto>
  fragmentedUnFocusedTimeInsertDtos;

  FocusTimeInsertDto({
    required this.startAt,
    required this.endAt,
    required this.createDate,
    required this.fragmentedUnFocusedTimeInsertDtos,
  });

  Map<String, dynamic> toJson() => {
    'startAt': startAt,
    'endAt': endAt,
    'createDate': createDate,
    'fragmentedUnFocusedTimeInsertDtos':
        fragmentedUnFocusedTimeInsertDtos.map((e) => e.toJson()).toList(),
  };

  String toJsonString() => jsonEncode(toJson());
}

/// GET 응답용 비집중 구간 DTO
class UnFocusedTimeDto {
  final int id;
  final int focusId;
  final String startAt; // HH:mm:ss
  final String endAt; // HH:mm:ss
  final UnFocusedType type;
  final int unfocusedTime; // seconds

  UnFocusedTimeDto({
    required this.id,
    required this.focusId,
    required this.startAt,
    required this.endAt,
    required this.type,
    required this.unfocusedTime,
  });

  factory UnFocusedTimeDto.fromJson(Map<String, dynamic> json) =>
      UnFocusedTimeDto(
        id: (json['id'] as num).toInt(),
        focusId: (json['focusId'] as num).toInt(),
        startAt: json['startAt'] as String,
        endAt: json['endAt'] as String,
        type: parseUnFocusedType(json['type'] as String),
        unfocusedTime: (json['unfocusedTime'] as num).toInt(),
      );
}

/// GET 응답용 집중 구간 DTO
class FocusTimeResponseDto {
  final int id;
  final String memberId;
  final String startAt; // HH:mm:ss
  final String endAt; // HH:mm:ss
  final String createDate; // YYYY-MM-DD
  final List<UnFocusedTimeDto> unFocusedTimeDtos;

  FocusTimeResponseDto({
    required this.id,
    required this.memberId,
    required this.startAt,
    required this.endAt,
    required this.createDate,
    required this.unFocusedTimeDtos,
  });

  factory FocusTimeResponseDto.fromJson(Map<String, dynamic> json) {
    final dynamic rawList = json['unFocusedTimeDtos'];
    final List<UnFocusedTimeDto> parsedList;
    if (rawList is List) {
      parsedList =
          rawList
              .whereType<Map<String, dynamic>>()
              .map(UnFocusedTimeDto.fromJson)
              .toList();
    } else {
      parsedList = <UnFocusedTimeDto>[];
    }

    return FocusTimeResponseDto(
      id: (json['id'] as num).toInt(),
      memberId: json['memberId']?.toString() ?? '',
      startAt: json['startAt'] as String,
      endAt: json['endAt'] as String,
      createDate: json['createDate'] as String,
      unFocusedTimeDtos: parsedList,
    );
  }
}

/// 공통 에러 응답
class ApiErrorResponse {
  final int code;
  final String message;
  final String? detail;

  ApiErrorResponse({required this.code, required this.message, this.detail});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) =>
      ApiErrorResponse(
        code: json['code'] as int,
        message: json['message'] as String,
        detail: json['detail'] as String?,
      );

  @override
  String toString() =>
      'ApiErrorResponse(code: $code, message: $message, detail: $detail)';
}

/// API 호출 예외
class FocusTimeApiException implements Exception {
  final ApiErrorResponse error;
  final int statusCode;

  FocusTimeApiException({required this.error, required this.statusCode});

  @override
  String toString() =>
      'FocusTimeApiException(statusCode: $statusCode, error: $error)';
}
