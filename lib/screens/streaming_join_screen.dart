import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:focused_study_time_tracker/models/study_room.dart';
import 'package:focused_study_time_tracker/screens/streaming_screen.dart';
import 'package:intl/intl.dart';

class StreamingJoinScreen extends StatefulWidget {
  const StreamingJoinScreen({super.key});

  @override
  State<StreamingJoinScreen> createState() => _StreamingJoinScreenState();
}

class _StreamingJoinScreenState extends State<StreamingJoinScreen> {
  final List<StudyRoom> _rooms = []; // TODO: 실제 서버에서 방 목록을 가져와야 합니다
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      // TODO: 실제 서버 API 호출로 대체
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _rooms.addAll([
          StudyRoom(
            id: '1',
            name: '열심히 공부하는 방',
            hostName: '김철수',
            participantCount: 3,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          StudyRoom(
            id: '2',
            name: '프로그래밍 스터디',
            hostName: '이영희',
            participantCount: 2,
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ]);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('방 목록을 불러오는데 실패했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createRoom() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _CreateRoomDialog(),
    );

    if (result != null && mounted) {
      // TODO: 실제 서버 API 호출로 대체
      final newRoom = StudyRoom(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result['name']!,
        hostName: result['hostName']!,
        participantCount: 1,
        createdAt: DateTime.now(),
      );

      setState(() => _rooms.insert(0, newRoom));

      // 새로 생성한 방으로 바로 입장
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => StreamingScreen(
                  roomName: newRoom.id,
                  participantName: newRoom.hostName,
                ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      appBar: AppBar(
        title: const Text('스터디룸'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _createRoom),
        ],
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadRooms,
                child:
                    _rooms.isEmpty
                        ? const Center(
                          child: Text(
                            '현재 진행 중인 스터디룸이 없습니다.\n새로운 스터디룸을 만들어보세요!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _rooms.length,
                          itemBuilder: (context, index) {
                            final room = _rooms[index];
                            return _RoomCard(
                              room: room,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => StreamingScreen(
                                          roomName: room.id,
                                          participantName:
                                              '참가자', // TODO: 실제 사용자 이름으로 대체
                                        ),
                                  ),
                                );
                              },
                            );
                          },
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${room.participantCount}명 참여 중',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '호스트: ${room.hostName}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '시작: ${DateFormat('MM/dd HH:mm').format(room.createdAt)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
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
  final _hostNameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _hostNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새로운 스터디룸 만들기'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '방 이름',
                hintText: '예: 열심히 공부하는 방',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '방 이름을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hostNameController,
              decoration: const InputDecoration(
                labelText: '호스트 이름',
                hintText: '예: 김철수',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '호스트 이름을 입력해주세요';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'hostName': _hostNameController.text,
              });
            }
          },
          child: const Text('만들기'),
        ),
      ],
    );
  }
}
