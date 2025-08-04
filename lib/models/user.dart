class User {
  final String memberId;
  final String nickName;
  final String email;

  User({required this.memberId, required this.nickName, required this.email});

  // JSON에서 User 객체 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      memberId: json['memberId'] as String,
      nickName: json['nickName'] as String,
      email: json['email'] as String,
    );
  }

  // User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {'memberId': memberId, 'nickName': nickName, 'email': email};
  }

  // 사용자 정보 복사 (일부 필드만 변경)
  User copyWith({String? memberId, String? nickName, String? email}) {
    return User(
      memberId: memberId ?? this.memberId,
      nickName: nickName ?? this.nickName,
      email: email ?? this.email,
    );
  }

  // 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.memberId == memberId &&
        other.nickName == nickName &&
        other.email == email;
  }

  // 해시코드
  @override
  int get hashCode {
    return memberId.hashCode ^ nickName.hashCode ^ email.hashCode;
  }

  // 문자열 표현
  @override
  String toString() {
    return 'User(memberId: $memberId, nickName: $nickName, email: $email)';
  }
}
