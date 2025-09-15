import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_study_time_tracker/components/form_dialog.dart';
import 'package:focused_study_time_tracker/services/livekit.dart';
import 'package:focused_study_time_tracker/services/user_service.dart';
import 'package:go_router/go_router.dart';

/// 공용 스트리밍 관련 액션 모음
class StreamingActions {
  StreamingActions._();

  static final LiveKitService _liveKitService = LiveKitService();
  static final UserService _userService = UserService();

  /// 방 생성 플로우를 어디서든 호출 가능하게 제공
  static Future<void> createRoomFlow(BuildContext context) async {
    final result = await showFormDialog(
      context,
      title: '방 생성',
      fields: [
        const FormDialogFieldConfig(id: 'name', hintText: '방 이름'),
        FormDialogFieldConfig(
          id: 'max',
          hintText: '최대 참가자',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
      primaryButtonText: '생성하기',
    );

    if (result == null) return;

    final String roomName = result['name']?.trim() ?? '';
    final int maxParticipant = int.tryParse((result['max'] ?? '').trim()) ?? 10;
    if (roomName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('방 이름을 입력해주세요')));
      return;
    }

    final String nickname = await _userService.getNickname() ?? '나';

    try {
      await _liveKitService.initialize();
      await _liveKitService.createRoomOnServer(
        roomName,
        maxParticipant: maxParticipant,
      );
      if (!context.mounted) return;
      context.push(
        '/streaming_room',
        extra: {'roomName': roomName, 'participantName': nickname},
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('방 생성/입장 실패: $e')));
    }
  }
}
