import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:focused_study_time_tracker/const.dart';
import 'package:focused_study_time_tracker/services/login.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  String? token;
  String wsUrl = dotenv.env['LIVEKIT_URL'] ?? '';
  final LoginService _loginService = LoginService();

  Future<Map<String, String>> _authHeaders() async {
    return await _loginService.getAuthHeaders();
  }

  Future<String> createRoomAndGetToken(
    String roomName, {
    int maxParticipant = 10,
  }) async {
    final uri = Uri.parse('http://$baseUrl/api/rooms/create').replace(
      queryParameters: {
        'roomName': roomName,
        'maxParticipant': maxParticipant.toString(),
      },
    );

    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _authHeaders();
        return http.post(uri, headers: headers);
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(
        utf8.decode(response.bodyBytes),
      );
      final String livekitAccessToken =
          jsonBody['livekitAccessToken'] as String;
      return livekitAccessToken;
    }
    throw Exception('방 생성/토큰 발급 실패: ${response.statusCode} ${response.body}');
  }

  Future<String> joinRoomAndGetToken(String roomName) async {
    final uri = Uri.parse('http://$baseUrl/api/rooms/$roomName');
    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _authHeaders();
        return http.post(uri, headers: headers);
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(
        utf8.decode(response.bodyBytes),
      );
      final String livekitAccessToken =
          jsonBody['livekitAccessToken'] as String;
      return livekitAccessToken;
    }
    throw Exception('룸 참여/토큰 발급 실패: ${response.statusCode} ${response.body}');
  }

  // ====== 추가: 룸/참가자 조회 및 삭제 ======
  Future<List<Map<String, dynamic>>?> fetchAllRooms() async {
    final uri = Uri.parse('http://$baseUrl/api/rooms');
    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _authHeaders();
        return http.get(uri, headers: headers);
      },
    );

    if (response.statusCode == 200) {
      if (response.bodyBytes.isEmpty) {
        return [];
      }
      final List<dynamic> list = json.decode(utf8.decode(response.bodyBytes));

      return list.cast<Map<String, dynamic>>();
    }
    if (response.statusCode == 204) {
      return [];
    }
    throw Exception('전체 룸 조회 실패: ${response.statusCode} ${response.body}');
  }

  Future<List<Map<String, dynamic>>> fetchParticipants(String roomName) async {
    final uri = Uri.parse('http://$baseUrl/api/rooms/$roomName/participant');
    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _authHeaders();
        return http.get(uri, headers: headers);
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode(utf8.decode(response.bodyBytes));
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception('참가자 조회 실패: ${response.statusCode} ${response.body}');
  }

  Future<void> deleteRoom(String roomName) async {
    final uri = Uri.parse('http://$baseUrl/api/rooms/$roomName');
    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _authHeaders();
        return http.delete(uri, headers: headers);
      },
    );
    if (response.statusCode != 200) {
      throw Exception('룸 삭제 실패: ${response.statusCode} ${response.body}');
    }
  }
}
