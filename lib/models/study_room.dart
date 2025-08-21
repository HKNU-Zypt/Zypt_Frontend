class StudyRoom {
  final String id;
  final String name;
  final int numParticipants;
  final int maxParticipants;
  final bool isActive;

  StudyRoom({
    required this.id,
    required this.name,
    required this.numParticipants,
    required this.maxParticipants,
    this.isActive = true,
  });

  // 서버 응답(roomId, roomName, numParticipants, maxParticipants)에 맞춘 변환
  // 일부 로컬 키(id, name, participantCount)도 허용하여 유연하게 처리
  factory StudyRoom.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id'] ?? json['roomId'];
    final dynamic nameValue = json['name'] ?? json['roomName'];
    final dynamic currentCountValue = json['numParticipants'];
    final dynamic maxCountValue = json['maxParticipants'];

    return StudyRoom(
      id: idValue?.toString() ?? '',
      name: nameValue?.toString() ?? '',
      numParticipants: (currentCountValue as num?)?.toInt() ?? 0,
      maxParticipants: (maxCountValue as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'numParticipants': numParticipants,
      'maxParticipants': maxParticipants,
      'isActive': isActive,
    };
  }
}
