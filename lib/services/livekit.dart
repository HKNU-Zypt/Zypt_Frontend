import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  Room? _room;
  String? _token;
  String? _wsUrl;
  LocalVideoTrack? _videoTrack;
  LocalAudioTrack? _audioTrack;

  Future<void> initialize() async {
    _wsUrl = dotenv.env['LIVEKIT_URL'];
    if (_wsUrl == null) {
      throw Exception('LIVEKIT_URL is not set in .env file');
    }
  }

  String getServerUrl(String roomName, String participantName) {
    //TODO: 실제 기기에서는 PC의 IP로 바꿔주세요! WIFI 달라질 떄마다 바꿔줘야함
    const pcIp = '192.168.0.19'; // 여기에 PC의 실제 IP 입력

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/getToken?room=$roomName&identity=$participantName';
    } else if (Platform.isIOS) {
      return 'http://$pcIp:8080/getToken?room=$roomName&identity=$participantName';
    } else {
      return 'http://localhost:8080/getToken?room=$roomName&identity=$participantName';
    }
  }

  Future<String> _getTokenFromServer(
    String roomName,
    String participantName,
  ) async {
    final response = await http.get(
      Uri.parse(getServerUrl(roomName, participantName)),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('토큰 발급 실패: ${response.statusCode}');
    }
  }

  Future<void> connect(String roomName, String participantName) async {
    try {
      _token = await _getTokenFromServer(roomName, participantName);
      _room = Room();

      if (_wsUrl == null || _token == null) {
        throw Exception('LiveKit URL or token is not initialized');
      }

      await _room!.connect(_wsUrl!, _token!);
    } catch (e) {
      _room = null;
      throw Exception('LiveKit 방 연결 실패: $e');
    }
  }

  Future<void> disconnect() async {
    if (_room != null) {
      await unpublishAll();
      await _room!.disconnect();
      _room = null;
    }
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
      if (_videoTrack != null) {
        await unpublishVideo();
      }
      _videoTrack = await LocalVideoTrack.createCameraTrack();
      await _room!.localParticipant!.publishVideoTrack(_videoTrack!);
    } catch (e) {
      throw Exception('Failed to publish video: $e');
    }
  }

  Future<void> publishAudio() async {
    if (_room == null) {
      throw Exception('Room is not initialized. Call connect() first.');
    }

    try {
      if (_audioTrack != null) {
        await unpublishAudio();
      }
      _audioTrack = await LocalAudioTrack.create();
      await _room!.localParticipant!.publishAudioTrack(_audioTrack!);
    } catch (e) {
      throw Exception('Failed to publish audio: $e');
    }
  }

  Future<void> unpublishVideo() async {
    if (_videoTrack != null) {
      await _videoTrack!.stop();
      _videoTrack = null;
    }
  }

  Future<void> unpublishAudio() async {
    if (_audioTrack != null) {
      await _audioTrack!.stop();
      _audioTrack = null;
    }
  }

  Future<void> unpublishAll() async {
    await unpublishVideo();
    await unpublishAudio();
  }
}
