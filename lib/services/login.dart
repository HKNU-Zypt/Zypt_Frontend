import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginService {
  static final LoginService _instance = LoginService._internal();
  factory LoginService() => _instance;
  LoginService._internal();
  // 안드로이드 용 baseUrl
  String baseUrl = '10.0.2.2:8080';
  // iOS 용 baseUrl
  // String baseUrl = '127.0.0.1:8080';

  Future<bool> loginWithKakao() async {
    OAuthToken? token;

    // 카카오 로그인 구현 예제
    if (await isKakaoTalkInstalled()) {
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return false;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          token = await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
        return false;
      }
    }

    if (token != null && token.idToken != null) {
      // 로컬 서버에 idToken 전달하여 자체 토큰 발급
      await loginWithIdToken('KAKAO', token.idToken!);
      print('자체 토큰 발급 성공');
      return true;
    }
    return false;
  }

  Future<void> loginWithApple() async {
    // 애플 로그인 구현 예제
  }

  Future<void> loginWithGoogle() async {
    // 구글 로그인 구현 예제
  }

  Future<void> loginWithNaver() async {
    // 네이버 로그인 구현 예제
  }

  // 로컬 서버에 idToken 전달하여 자체 토큰 발급
  Future<void> loginWithIdToken(String type, String idToken) async {
    // 로컬 서버에 idToken 전달하여 자체 토큰 발급
    print('idToken: $idToken');
    //localhost:8080/api/login

    // request body
    // type : KAKAO, GOOGLE, APPLIE, NAVER
    // token : 토큰값

    final response = await http.post(
      Uri.parse('http://$baseUrl/api/login'),
      body: {'type': type, 'token': idToken},
    );
    if (response.statusCode == 200) {
      print('response: ${response.body}');
      // 발급받은 토큰을 SharedPreferences에 저장
    } else {
      print('response: ${response.body}');
    }
    // 발급받은 토큰을 클라이언트에 저장
  }
}
