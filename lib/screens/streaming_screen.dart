import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:focused_study_time_tracker/services/livekit.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class StreamingScreen extends StatefulWidget {
  final String roomName;
  final String participantName;

  const StreamingScreen({
    super.key,
    required this.roomName,
    required this.participantName,
  });

  @override
  State<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
  final LiveKitService _liveKitService = LiveKitService();
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _initializeLiveKit();
  }

  void _onRoomDidUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeLiveKit() async {
    setState(() => _isConnecting = true);
    try {
      await _liveKitService.initialize();
      await _liveKitService.connect(widget.roomName, widget.participantName);
      _liveKitService.room.addListener(_onRoomDidUpdate);
      await _liveKitService.publishVideo();
      await _liveKitService.publishAudio();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('연결 실패: $e')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  @override
  void dispose() {
    _liveKitService.room.removeListener(_onRoomDidUpdate);
    _liveKitService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnecting) {
      return DefaultLayout(child: Center(child: CircularProgressIndicator()));
    }

    return DefaultLayout(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.roomName),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      child: Theme(
        data: ThemeData.dark(),
        child: Stack(
          children: [
            // 참가자 비디오 그리드
            Positioned.fill(child: _buildParticipantGrid()),
            // 하단 컨트롤 바
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: Colors.black.withOpacity(0.3),
                child: _buildControlBar(),
              ),
            ),
            // 연결 상태 표시
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: _buildConnectionStatus(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final localParticipant = _liveKitService.room.localParticipant;
        final remoteParticipants =
            _liveKitService.room.remoteParticipants.values.toList();
        final allParticipants = [
          if (localParticipant != null) localParticipant,
          ...remoteParticipants,
        ];

        if (allParticipants.isEmpty) {
          return const Center(
            child: Text('참가자가 없습니다', style: TextStyle(color: Colors.white)),
          );
        }

        final columns = (allParticipants.length < 2) ? 1 : 2;
        final rows = (allParticipants.length + columns - 1) ~/ columns;

        final aspectRatio =
            (constraints.maxHeight <= 0 || rows <= 0)
                ? 1.0
                : (constraints.maxWidth / constraints.maxHeight * rows).clamp(
                  0.1,
                  3.0,
                );

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: allParticipants.length,
          itemBuilder: (context, index) {
            final participant = allParticipants[index];
            return participant is lk.LocalParticipant
                ? _buildLocalParticipantView(participant)
                : _buildParticipantView(participant as lk.RemoteParticipant);
          },
        );
      },
    );
  }

  Widget _buildLocalParticipantView(lk.LocalParticipant participant) {
    final videoPublications = participant.trackPublications.values.where(
      (pub) => pub.kind == lk.TrackType.VIDEO && !pub.isScreenShare,
    );
    final videoTrack =
        videoPublications.firstOrNull?.track as lk.LocalVideoTrack?;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          if (videoTrack != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: lk.VideoTrackRenderer(videoTrack),
              ),
            ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '나',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantView(lk.RemoteParticipant participant) {
    final videoPublications = participant.trackPublications.values.where(
      (pub) => pub.kind == lk.TrackType.VIDEO && !pub.isScreenShare,
    );

    final videoTrack = videoPublications.firstOrNull?.track as lk.VideoTrack?;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          if (videoTrack != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: lk.VideoTrackRenderer(videoTrack),
              ),
            ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Text(
              participant.name ?? participant.identity,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                shadows: [Shadow(blurRadius: 3, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    final localParticipant = _liveKitService.localParticipant;
    if (localParticipant == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.black.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              localParticipant.hasVideo ? Icons.videocam : Icons.videocam_off,
              color: Colors.white,
            ),
            onPressed: () async {
              try {
                if (localParticipant.hasVideo) {
                  await _liveKitService.unpublishVideo();
                } else {
                  await _liveKitService.publishVideo();
                }
                if (mounted) setState(() {});
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('카메라 제어 중 오류 발생: $e')));
                }
              }
            },
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              localParticipant.hasAudio ? Icons.mic : Icons.mic_off,
              color: Colors.white,
            ),
            onPressed: () async {
              try {
                if (localParticipant.hasAudio) {
                  await _liveKitService.unpublishAudio();
                } else {
                  await _liveKitService.publishAudio();
                }
                if (mounted) setState(() {});
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('마이크 제어 중 오류 발생: $e')));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final connectionState = _liveKitService.room.connectionState;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: Colors.black45,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  connectionState == lk.ConnectionState.connected
                      ? Colors.green
                      : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            connectionState == lk.ConnectionState.connected ? '연결됨' : '연결 중...',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
