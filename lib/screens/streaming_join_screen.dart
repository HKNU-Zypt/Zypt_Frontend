import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/statsCard.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:focused_study_time_tracker/models/study_room.dart';
import 'package:focused_study_time_tracker/services/livekit.dart';
import 'package:focused_study_time_tracker/services/user_service.dart';
import 'package:focused_study_time_tracker/components/circle_icon_button.dart';
import 'package:go_router/go_router.dart';

class StreamingJoinScreen extends StatefulWidget {
  const StreamingJoinScreen({super.key});

  @override
  State<StreamingJoinScreen> createState() => _StreamingJoinScreenState();
}

class _StreamingJoinScreenState extends State<StreamingJoinScreen> {
  final LiveKitService _liveKitService = LiveKitService();
  final UserService _userService = UserService();
  final List<StudyRoom> _rooms = [];
  final List<StudyRoom> _filteredRooms = [];
  String? _nickname;
  String _searchQuery = '';
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNickname();
    _loadRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  // 검색어로 방 목록 필터링
  void _filterRooms(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredRooms.clear();
        _isSearchMode = false;
      } else {
        _isSearchMode = true;
        _filteredRooms
          ..clear()
          ..addAll(
            _rooms.where(
              (room) => room.name.toLowerCase().contains(query.toLowerCase()),
            ),
          );
      }
    });
  }

  // 검색 모드 토글
  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (!_isSearchMode) {
        _searchController.clear();
        _searchQuery = '';
        _filteredRooms.clear();
      } else {
        _searchController.clear();
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      appBar: AppBar(
        leadingWidth: 100,
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        actions: [
          if (_isSearchMode)
            Expanded(
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterRooms,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onTapOutside: (_) {
                    if (_searchQuery.isEmpty) {
                      _toggleSearchMode();
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: '방 제목 검색...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          if (!_isSearchMode) ...[
            CircleIconButton(
              icon: Icons.search,
              onTap: _toggleSearchMode,
              backgroundColor: Colors.black,
              iconColor: Colors.white,
            ),
            const SizedBox(width: 8),
          ],
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
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'SoyoMaple',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadRooms,
                child:
                    _rooms.isEmpty && !_isSearchMode
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
                        : _isSearchMode && _filteredRooms.isEmpty
                        ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  '"$_searchQuery"에 대한 검색 결과가 없습니다.\n다른 검색어를 입력해보세요.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
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
                          itemCount:
                              _isSearchMode
                                  ? _filteredRooms.length
                                  : _rooms.length,
                          itemBuilder: (context, index) {
                            final room =
                                _isSearchMode
                                    ? _filteredRooms[index]
                                    : _rooms[index];
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
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder:
                                  //         (context) => StreamingScreen(
                                  //           roomName: room.name,
                                  //           participantName: nickname,
                                  //         ),
                                  //   ),
                                  // );
                                  // 입장 토큰 발급 후 라우팅
                                  final token = await _liveKitService
                                      .joinRoomAndGetToken(room.name);
                                  if (!mounted) return;
                                  context.push(
                                    '/streaming_room',
                                    extra: {
                                      'roomName': room.name,
                                      'participantName': nickname,
                                      'token': token,
                                    },
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
            // 참가자 수 / 최대 참가자 수
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
                // 참가자 수 / 최대 참가자 수
                Text(
                  '${room.numParticipants}/${room.maxParticipants}',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
