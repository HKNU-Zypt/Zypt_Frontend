import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:focused_study_time_tracker/services/livekit.dart';
import 'package:livekit_components/livekit_components.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class StreamingScreen extends StatefulWidget {
  final String token;
  final String roomName;

  const StreamingScreen({
    super.key,
    required this.token,
    required this.roomName,
  });

  @override
  State<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
  final LiveKitService _liveKitService = LiveKitService();

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.roomName),
        backgroundColor: Colors.white,
      ),
      child: LivekitRoom(
        roomContext: RoomContext(
          connect: true,
          url: _liveKitService.wsUrl,
          token: widget.token,
        ),
        builder: (context, roomCtx) {
          return Stack(
            children: [
              Positioned.fill(
                child: ParticipantLoop(
                  layoutBuilder: const CarouselLayoutBuilder(),
                  participantTrackBuilder:
                      (context, identifier) =>
                          const _CoverVideoParticipantTile(),
                  showAudioTracks: false,
                  showVideoTracks: true,
                  showParticipantPlaceholder: true,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: const ControlBar(
                      selectedColor: Color(0xFF6BAB93),
                      microphone: true,
                      audioOutput: false,
                      camera: true,
                      chat: false,
                      screenShare: false,
                      leave: false,
                      settings: false,
                      showTitleWidget: false,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CoverVideoParticipantTile extends StatelessWidget {
  const _CoverVideoParticipantTile();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        // 비디오가 컨테이너를 꽉 채우도록 cover 사용
        VideoTrackWidget(fit: lk.VideoViewFit.cover),
        Positioned(top: 0, right: 0, child: FocusToggle()),
        Positioned(top: 8, left: 0, child: TrackStatsWidget()),
        ParticipantStatusBar(),
      ],
    );
  }
}
