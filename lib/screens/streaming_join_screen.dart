import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_study_time_tracker/components/statsCard.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:focused_study_time_tracker/models/study_room.dart';
import 'package:focused_study_time_tracker/screens/streaming_screen.dart';
import 'package:focused_study_time_tracker/services/livekit.dart';
import 'package:focused_study_time_tracker/services/user_service.dart';
import 'package:focused_study_time_tracker/components/circle_icon_button.dart';

class StreamingJoinScreen extends StatefulWidget {
  const StreamingJoinScreen({super.key});

  @override
  State<StreamingJoinScreen> createState() => _StreamingJoinScreenState();
}

class _StreamingJoinScreenState extends State<StreamingJoinScreen> {
  final LiveKitService _liveKitService = LiveKitService();
  final UserService _userService = UserService();
  final List<StudyRoom> _rooms = [];
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _loadNickname();
    _loadRooms();
  }

  Future<void> _loadNickname() async {
    final nick = await _userService.getNickname();
    if (!mounted) return;
    setState(() {
      _nickname = nick;
    });
  }

  Future<void> _loadRooms() async {
    try {
      print('zypt [StreamingJoinScreen] _loadRooms - 방 목록 불러오기 시작');
      final rooms = await _liveKitService.fetchAllRooms();
      print('rooms: $rooms');
      setState(() {
        _rooms
          ..clear()
          ..addAll(
            (rooms ?? []).map((e) {
              // 백엔드 DTO: roomName, roomId, emptyTimeOut, maxParticipants, numParticipants
              return StudyRoom(
                id: e['roomId'].toString(),
                name: e['roomName'] as String,
                numParticipants: (e['numParticipants'] as num?)?.toInt() ?? 0,
                maxParticipants: (e['maxParticipants'] as num?)?.toInt() ?? 0,
              );
            }),
          );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('방 목록을 불러오는데 실패했습니다: $e')));
      }
    }
  }

  // 데모용: 다양한 참가자 수를 가진 방 목록을 즉시 주입
  void _populateMockRooms() {
    final List<StudyRoom> mockRooms = [
      StudyRoom(
        id: 'r1',
        name: '좋은 정보 공유',
        numParticipants: 1,
        maxParticipants: 8,
      ),
      StudyRoom(
        id: 'r2',
        name: '꾸준히 공부해요',
        numParticipants: 3,
        maxParticipants: 8,
      ),
      StudyRoom(
        id: 'r3',
        name: '집중 모드 ON',
        numParticipants: 5,
        maxParticipants: 8,
      ),
      StudyRoom(
        id: 'r4',
        name: '시험 대비 스터디',
        numParticipants: 8,
        maxParticipants: 8,
      ),
      StudyRoom(
        id: 'r5',
        name: '개발 면접 준비',
        numParticipants: 11,
        maxParticipants: 12,
      ),
    ];
    if (!mounted) return;
    setState(() {
      _rooms
        ..clear()
        ..addAll(mockRooms);
    });
  }

  Future<void> _createRoom() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _CreateRoomDialog(),
    );

    if (result != null && mounted) {
      final roomName = result['name']!;
      final maxStr = result['max'];
      final int maxParticipant = int.tryParse(maxStr ?? '') ?? 10;
      final nickname = _nickname ?? await _userService.getNickname() ?? '나';
      try {
        // 방만 생성하고 연결은 StreamingScreen에서 수행
        await _liveKitService.initialize();
        await _liveKitService.createRoomOnServer(
          roomName,
          maxParticipant: maxParticipant,
        );
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => StreamingScreen(
                  roomName: roomName,
                  participantName: nickname,
                ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('방 생성/입장 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      appBar: AppBar(
        leadingWidth: 100,
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            CircleIconButton(
              icon: Icons.notes_outlined,
              onTap: _populateMockRooms,
              backgroundColor: Colors.black,
              iconColor: Colors.white,
            ),
            const SizedBox(width: 8),
            CircleIconButton(
              icon: Icons.add,
              onTap: _createRoom,
              backgroundColor: Colors.white,
              iconColor: Colors.black,
              borderColor: Colors.grey,
            ),
          ],
        ),
        actions: [
          CircleIconButton(
            icon: Icons.search,
            onTap: () {},
            backgroundColor: Colors.black,
            iconColor: Colors.white,
          ),
          const SizedBox(width: 8),
          CircleIconButton(
            icon: Icons.circle_notifications,
            onTap: () {},
            backgroundColor: const Color(0xFF222222),
            iconColor: Colors.white,
          ),
          const SizedBox(width: 8),
          CircleIconButton(
            icon: Icons.face,
            onTap: () {},
            backgroundColor: Colors.white,
            iconColor: Colors.black,
            borderColor: Colors.black54,
          ),
          const SizedBox(width: 8),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Start Your Day &\nBe Productive',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'SoyoMaple',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadRooms,
                child:
                    _rooms.isEmpty
                        ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  '현재 진행 중인 스터디룸이 없습니다.\n새로운 스터디룸을 만들어보세요!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _rooms.length,
                          itemBuilder: (context, index) {
                            final room = _rooms[index];
                            return _RoomCard(
                              room: room,
                              onTap: () async {
                                try {
                                  final nickname =
                                      _nickname ??
                                      await _userService.getNickname() ??
                                      '나';
                                  if (!mounted) return;
                                  // 연결은 StreamingScreen에서 수행
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => StreamingScreen(
                                            roomName: room.name,
                                            participantName: nickname,
                                          ),
                                    ),
                                  );
                                } catch (e) {
                                  print(e);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('입장 실패: $e')),
                                  );
                                }
                              },
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final StudyRoom room;
  final VoidCallback onTap;

  const _RoomCard({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final int maxAvatarsToShow = 4;
    final int avatarsToShow =
        room.numParticipants > maxAvatarsToShow
            ? maxAvatarsToShow
            : room.numParticipants;
    final int extraCount = (room.numParticipants - avatarsToShow).clamp(0, 50);
    final int safeMax = room.maxParticipants == 0 ? 1 : room.maxParticipants;
    final double progress = (room.numParticipants / safeMax).clamp(0.0, 1.0);
    const List<IconData> faceIconOptions = [
      Icons.face,
      Icons.face_2,
      Icons.face_3,
      Icons.face_4,
      Icons.face_5,
      Icons.face_6,
    ];

    return OffsetOutlinedCard(
      padding: const EdgeInsets.all(16),
      outerPadding: const EdgeInsets.fromLTRB(15, 0, 15, 24),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2),
                      // 제목
                      Text(
                        room.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'AppleSDGothicNeo',
                        ),
                      ),
                      SizedBox(height: 8),
                      // 설명 두 줄
                      Text(
                        'sub\n공부할 때 꿀팁 같이 공유해요',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          fontFamily: 'AppleSDGothicNeo',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.pending, size: 24),
              ],
            ),
            const SizedBox(height: 10),
            // 참가자 아바타 + 추가 인원
            Row(
              children: [
                for (int i = 0; i < avatarsToShow; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      right: i == avatarsToShow - 1 ? 6 : 0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black87, width: 1.2),
                      ),
                      height: 32,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        child: Icon(
                          faceIconOptions[(room.id.hashCode + i) %
                              faceIconOptions.length],
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                if (extraCount > 0)
                  Text(
                    '$extraCount+',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // 진행 바 + 시간
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black87, width: 1.2),
                        ),
                      ),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('4:30', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateRoomDialog extends StatefulWidget {
  const _CreateRoomDialog();

  @override
  State<_CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<_CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maxController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'max': _maxController.text.trim(),
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.black87, width: 1.2),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      title: const Text(
        '방 생성',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'AppleSDGothicNeo',
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PillTextField(
              controller: _nameController,
              hintText: '방 이름',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '방 이름을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _PillTextField(
              controller: _maxController,
              hintText: '최대 참가자',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _submit(),
              validator: (value) {
                final v = int.tryParse((value ?? '').trim());
                if (v == null || v <= 0) {
                  return '최대 참가자를 숫자로 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _submit,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: const StadiumBorder(),
                side: const BorderSide(color: Colors.black87, width: 1.2),
                backgroundColor: const Color(0xFFEFEFEF),
                foregroundColor: Colors.black,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('생성하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillTextField extends StatelessWidget {
  const _PillTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onSubmitted,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.grey,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
