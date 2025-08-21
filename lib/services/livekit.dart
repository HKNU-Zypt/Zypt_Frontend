import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:focused_study_time_tracker/const.dart';
import 'package:focused_study_time_tracker/services/login.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  Room? _room;
  String? _token;
  String? _wsUrl;
  final LoginService _loginService = LoginService();
  VoidCallback? _roomListener;
  bool _useFrontCamera = true;

  // 참가자/미디어/연결 상태 브로드캐스트
  final ValueNotifier<ParticipantsState> participantsStateNotifier =
      ValueNotifier<ParticipantsState>(
        const ParticipantsState(localParticipant: null, remoteParticipants: []),
      );
  final ValueNotifier<bool> cameraEnabledNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> microphoneEnabledNotifier = ValueNotifier<bool>(
    false,
  );
  final ValueNotifier<ConnectionState> connectionStateNotifier =
      ValueNotifier<ConnectionState>(ConnectionState.disconnected);

  bool get isRoomInitialized => _room != null;

  Future<void> initialize() async {
    _wsUrl = dotenv.env['LIVEKIT_URL'];
    if (_wsUrl == null) {
      throw Exception('LIVEKIT_URL is not set in .env file');
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final accessToken = await _loginService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('인증 토큰이 없습니다. 먼저 로그인 해주세요.');
    }
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  Future<http.Response> _authorizedRequest(
    Future<http.Response> Function() requestFn,
  ) async {
    http.Response response = await requestFn();
    if (response.statusCode == 401) {
      final refreshed = await _loginService.refreshAccessToken();
      if (refreshed) {
        response = await requestFn();
      }
    }
    return response;
  }

  Future<String> _createRoomAndGetToken(
    String roomName, {
    int maxParticipant = 10,
  }) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('http://$baseUrl/api/rooms/create').replace(
      queryParameters: {
        'roomName': roomName,
        'maxParticipant': maxParticipant.toString(),
      },
    );

    final response = await _authorizedRequest(
      () => http.post(uri, headers: headers),
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

  Future<String> _joinRoomAndGetToken(String roomName) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('http://$baseUrl/api/rooms/$roomName');
    final response = await _authorizedRequest(
      () => http.post(uri, headers: headers),
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

  Future<void> connect(String roomName, String participantName) async {
    try {
      // 백엔드에서 닉네임/식별자는 액세스 토큰으로 파생되므로 participantName은 서버에 전달하지 않습니다.
      _token = await _joinRoomAndGetToken(roomName);
      _room = Room();

      if (_wsUrl == null || _token == null) {
        throw Exception('LiveKit URL or token is not initialized');
      }

      await _room!.connect(_wsUrl!, _token!);
      _attachRoomListener();
      _emitState();
    } catch (e) {
      _room = null;
      throw Exception('LiveKit 방 연결 실패: $e');
    }
  }

  Future<void> createAndConnect(
    String roomName, {
    int maxParticipant = 10,
  }) async {
    try {
      _token = await _createRoomAndGetToken(
        roomName,
        maxParticipant: maxParticipant,
      );
      _room = Room();

      if (_wsUrl == null || _token == null) {
        throw Exception('LiveKit URL or token is not initialized');
      }

      await _room!.connect(_wsUrl!, _token!);
      _attachRoomListener();
      _emitState();
    } catch (e) {
      _room = null;
      throw Exception('LiveKit 방 생성/연결 실패: $e');
    }
  }

  // 방만 생성(백엔드에 방 생성 요청)하고 연결은 하지 않습니다.
  Future<void> createRoomOnServer(
    String roomName, {
    int maxParticipant = 10,
  }) async {
    try {
      await _createRoomAndGetToken(roomName, maxParticipant: maxParticipant);
    } catch (e) {
      throw Exception('LiveKit 방 생성 실패: $e');
    }
  }

  Future<void> disconnect() async {
    if (_room != null) {
      await unpublishAll();
      if (_roomListener != null) {
        _room!.removeListener(_roomListener!);
        _roomListener = null;
      }
      await _room!.disconnect();
      _room = null;
    }
    // 상태 초기화
    participantsStateNotifier.value = const ParticipantsState(
      localParticipant: null,
      remoteParticipants: [],
    );
    cameraEnabledNotifier.value = false;
    microphoneEnabledNotifier.value = false;
    connectionStateNotifier.value = ConnectionState.disconnected;
  }

  Room get room {
    if (_room == null) {
      throw Exception('Room is not initialized. Call connect() first.');
    }
    return _room!;
  }

  LocalParticipant? get localParticipant => _room?.localParticipant;

  List<RemoteParticipant> get remoteParticipants =>
      _room?.remoteParticipants.values.toList() ?? [];

  Future<void> publishVideo() async {
    if (_room == null) {
      throw Exception('Room is not initialized. Call connect() first.');
    }

    try {
      // LiveKit 권장 방식: 카메라 퍼블리시/언퍼블리시 토글
      await _room!.localParticipant!.setCameraEnabled(
        true,
        cameraCaptureOptions: CameraCaptureOptions(
          cameraPosition:
              _useFrontCamera ? CameraPosition.front : CameraPosition.back,
        ),
      );
      cameraEnabledNotifier.value = true;
    } catch (e) {
      throw Exception('Failed to publish video: $e');
    }
  }

  Future<void> publishAudio() async {
    if (_room == null) {
      throw Exception('Room is not initialized. Call connect() first.');
    }

    try {
      // LiveKit 권장 방식: 마이크 퍼블리시/언퍼블리시 토글
      await _room!.localParticipant!.setMicrophoneEnabled(true);
      microphoneEnabledNotifier.value = true;
    } catch (e) {
      throw Exception('Failed to publish audio: $e');
    }
  }

  Future<void> unpublishVideo() async {
    if (_room?.localParticipant != null) {
      await _room!.localParticipant!.setCameraEnabled(false);
      cameraEnabledNotifier.value = false;
    }
  }

  Future<void> unpublishAudio() async {
    if (_room?.localParticipant != null) {
      await _room!.localParticipant!.setMicrophoneEnabled(false);
      microphoneEnabledNotifier.value = false;
    }
  }

  Future<void> unpublishAll() async {
    await unpublishVideo();
    await unpublishAudio();
  }

  // 권한 보장(1차: 최소 구현 - 플랫폼 기본 권한 요청 흐름에 위임)
  Future<void> ensurePermissions() async {
    // 추후 permission_handler 또는 SDK 내 권한 유틸을 연동할 수 있습니다.
    // 현재 단계에서는 setCameraEnabled/setMicrophoneEnabled 호출 시
    // 플랫폼 권한 프롬프트에 위임합니다.
    return;
  }

  // --- 편의 API ---
  bool get isCameraEnabled => cameraEnabledNotifier.value;
  bool get isMicrophoneEnabled => microphoneEnabledNotifier.value;

  Future<void> setCameraEnabled(bool enabled) async {
    if (_room?.localParticipant == null) {
      throw Exception('Room is not initialized. Call connect() first.');
    }
    await _room!.localParticipant!.setCameraEnabled(
      enabled,
      cameraCaptureOptions:
          enabled
              ? CameraCaptureOptions(
                cameraPosition:
                    _useFrontCamera
                        ? CameraPosition.front
                        : CameraPosition.back,
              )
              : null,
    );
    cameraEnabledNotifier.value = enabled;
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    if (_room?.localParticipant == null) {
      throw Exception('Room is not initialized. Call connect() first.');
    }
    await _room!.localParticipant!.setMicrophoneEnabled(enabled);
    microphoneEnabledNotifier.value = enabled;
  }

  Future<void> toggleCamera() async {
    await setCameraEnabled(!cameraEnabledNotifier.value);
  }

  Future<void> toggleMicrophone() async {
    await setMicrophoneEnabled(!microphoneEnabledNotifier.value);
  }

  Future<void> flipCamera() async {
    final local = _room?.localParticipant;
    if (local == null) {
      throw Exception('Room is not initialized. Call connect() first.');
    }
    _useFrontCamera = !_useFrontCamera;
    if (cameraEnabledNotifier.value) {
      await setCameraEnabled(true);
    }
  }

  void _attachRoomListener() {
    if (_room == null) return;
    _roomListener ??= _onRoomChanged;
    _room!.addListener(_roomListener!);
  }

  void _onRoomChanged() {
    _emitState();
  }

  void _emitState() {
    final local = _room?.localParticipant;
    final remotes = _room?.remoteParticipants.values.toList() ?? [];
    participantsStateNotifier.value = ParticipantsState(
      localParticipant: local,
      remoteParticipants: remotes,
    );
    cameraEnabledNotifier.value = local?.hasVideo ?? false;
    microphoneEnabledNotifier.value = local?.hasAudio ?? false;
    connectionStateNotifier.value =
        _room?.connectionState ?? ConnectionState.disconnected;
  }

  // ====== 추가: 룸/참가자 조회 및 삭제 ======
  Future<List<Map<String, dynamic>>?> fetchAllRooms() async {
    final headers = await _authHeaders();
    final uri = Uri.parse('http://$baseUrl/api/rooms');
    final response = await _authorizedRequest(
      () => http.get(uri, headers: headers),
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
    final headers = await _authHeaders();
    final uri = Uri.parse('http://$baseUrl/api/rooms/$roomName/participant');
    final response = await _authorizedRequest(
      () => http.get(uri, headers: headers),
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode(utf8.decode(response.bodyBytes));
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception('참가자 조회 실패: ${response.statusCode} ${response.body}');
  }

  Future<void> deleteRoom(String roomName) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('http://$baseUrl/api/rooms/$roomName');
    final response = await _authorizedRequest(
      () => http.delete(uri, headers: headers),
    );
    if (response.statusCode != 200) {
      throw Exception('룸 삭제 실패: ${response.statusCode} ${response.body}');
    }
  }
}

class ParticipantsState {
  final LocalParticipant? localParticipant;
  final List<RemoteParticipant> remoteParticipants;

  const ParticipantsState({
    required this.localParticipant,
    required this.remoteParticipants,
  });
}
