import 'dart:convert';
import 'package:focused_study_time_tracker/const.dart';
import 'package:focused_study_time_tracker/services/login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focused_study_time_tracker/models/user.dart';

class UserService {
  static const String _userKey = 'user_data';

  // 싱글톤 패턴
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final LoginService _loginService = LoginService();

  // 현재 사용자 정보 (메모리 캐시)
  User? _currentUser;

  // 현재 사용자 정보 가져오기
  User? get currentUser => _currentUser;

  // 사용자 정보 초기화 (앱 시작 시 호출)
  Future<void> initialize() async {
    await _loadUserFromStorage();
  }

  // SharedPreferences에서 사용자 정보 로드
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      print('zypt [UserService] _loadUserFromStorage - 저장된 데이터: $userJson');

      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
        print(
          'zypt [UserService] _loadUserFromStorage - 로드된 사용자: ${_currentUser?.nickName} (${_currentUser?.memberId})',
        );
      } else {
        print('zypt [UserService] _loadUserFromStorage - 저장된 데이터 없음');
      }
    } catch (e) {
      print('zypt [UserService] 사용자 정보 로드 실패: $e');
      _currentUser = null;
    }
  }

  // 사용자 정보 저장 (SharedPreferences)
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);

      _currentUser = user;
    } catch (e) {
      print('zypt [UserService] 사용자 정보 저장 실패: $e');
      throw Exception('사용자 정보 저장에 실패했습니다: $e');
    }
  }

  // 사용자 정보 삭제 (로그아웃)
  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 삭제 전 현재 상태 로깅
      final beforeUserJson = prefs.getString(_userKey);
      print('zypt [UserService] clearUser - 삭제 전 데이터: $beforeUserJson');

      await prefs.remove(_userKey);
      _currentUser = null;

      // 삭제 후 확인
      final afterUserJson = prefs.getString(_userKey);
      print('zypt [UserService] clearUser - 삭제 후 데이터: $afterUserJson');
      print('zypt [UserService] clearUser - 완료');
    } catch (e) {
      print('zypt [UserService] 사용자 정보 삭제 실패: $e');
      throw Exception('사용자 정보 삭제에 실패했습니다: $e');
    }
  }

  // 닉네임 가져오기
  Future<String?> getNickname() async {
    if (_currentUser != null && _currentUser!.nickName.isNotEmpty) {
      return _currentUser!.nickName;
    }
    final result = await getUser();
    if (result) {
      return _currentUser!.nickName;
    }
    print('zypt [UserService] 닉네임 가져오기 실패');
    return null;
  }

  // setNickname
  Future<bool> setNickname(String nickname) async {
    final uri = Uri.parse(
      'http://$baseUrl/api/member/signup?nickName=$nickname',
    );

    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _loginService.getAuthHeaders();
        return http.post(uri, headers: headers);
      },
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      // 닉네임 설정 성공 시 사용자 정보 업데이트
      final result = await getUser();
      if (result) {
        print('zypt [UserService] 닉네임 설정 성공');
        return true;
      } else {
        print('zypt [UserService] getUser 닉네임 설정 실패');
        return false;
      }
    } else {
      print('zypt [UserService] signup 닉네임 설정 실패');
      return false;
    }
  }

  // updateNickname
  Future<bool> updateNickname(String nickname) async {
    final uri = Uri.parse('http://$baseUrl/api/member?nickName=$nickname');

    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _loginService.getAuthHeaders();
        return http.patch(uri, headers: headers);
      },
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      // 닉네임 설정 성공 시 사용자 정보 업데이트
      final result = await getUser();
      if (result) {
        print('zypt [UserService] 닉네임 업데이트 성공');
        return true;
      } else {
        print('zypt [UserService] getUser 닉네임 업데이트 실패');
        return false;
      }
    } else {
      print('zypt [UserService]  닉네임 업데이트 실패');
      print('zypt [UserService] 닉네임 업데이트 실패: ${response.statusCode}');
      print('zypt [UserService] 닉네임 업데이트 실패: ${response.body}');
      return false;
    }
  }

  // User 정보 가져오기
  Future<bool> getUser() async {
    final uri = Uri.parse('http://$baseUrl/api/member');

    final response = await _loginService.authorizedRequest(
      () => () async {
        final headers = await _loginService.getAuthHeaders();
        return http.get(uri, headers: headers);
      },
    );
    if (response.statusCode == 200) {
      print('zypt [UserService] getUser - response: ${response.body}');
      final user = User.fromJson(json.decode(response.body));
      print(
        'zypt [UserService] getUser - user: ${user.nickName} (${user.memberId})',
      );
      await _saveUserToStorage(user);
      return true;
    } else {
      print('zypt [UserService] 사용자 정보 가져오기 실패');
      return false;
    }
  }
}
