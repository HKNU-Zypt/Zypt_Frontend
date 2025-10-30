// 안드로이드 용 baseUrl
// String baseUrl = '10.0.2.2:8080';
// String baseUrl = '192.168.219.106:8080';
String baseUrl = 'https://zyptapi.store';
// iOS 용 baseUrl
// String baseUrl = '127.0.0.1:8080';
// S10 용 baseUrl (노트북 사설 ip)
// String baseUrl = '192.168.45.127:8080';

/// API 엔드포인트용 URI를 생성합니다.
/// - baseUrl이 스킴을 포함하지 않으면 기본적으로 http를 사용합니다.
/// - baseUrl 끝의 슬래시는 제거되고, path는 선행 슬래시가 보장됩니다.
Uri buildApiUri(String path, [Map<String, dynamic>? query]) {
  String origin = baseUrl.trim();
  if (origin.isEmpty) {
    throw ArgumentError('baseUrl이 비어 있습니다.');
  }

  // 스킴이 없으면 기본적으로 http를 사용 (로컬/사설망 호환)
  final hasScheme =
      origin.startsWith('http://') || origin.startsWith('https://');
  if (!hasScheme) {
    origin = 'http://$origin';
  }

  // 끝의 슬래시 제거
  if (origin.endsWith('/')) {
    origin = origin.substring(0, origin.length - 1);
  }

  // path는 선행 슬래시 보장
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  final uri = Uri.parse('$origin$normalizedPath');

  if (query == null || query.isEmpty) {
    return uri;
  }
  return uri.replace(queryParameters: query.map((k, v) => MapEntry(k, '$v')));
}
