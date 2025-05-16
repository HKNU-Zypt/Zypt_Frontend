class StudyRoom {
  final String id;
  final String name;
  final String hostName;
  final int participantCount;
  final DateTime createdAt;
  final bool isActive;

  StudyRoom({
    required this.id,
    required this.name,
    required this.hostName,
    required this.participantCount,
    required this.createdAt,
    this.isActive = true,
  });

  // TODO: 실제 서버 API 연동 시 JSON 변환 메서드 추가
  factory StudyRoom.fromJson(Map<String, dynamic> json) {
    return StudyRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      hostName: json['hostName'] as String,
      participantCount: json['participantCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostName': hostName,
      'participantCount': participantCount,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}
