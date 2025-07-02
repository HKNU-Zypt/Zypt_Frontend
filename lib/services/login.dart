import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
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
      bool result = await loginWithSocialToken(
        'KAKAO',
        token.idToken!,
        token.refreshToken!,
      );
      if (result) {
        print('FROM KAKAO TO 자체 토큰 발급 성공');
        // 카카오 로그아웃 처리
        await UserApi.instance.logout();
        return true;
      } else {
        print('FROM KAKAO TO 자체 토큰 발급 실패');
        return false;
      }
    } else {
      print('카카오 로그인 실패');
      return false;
    }
  }

  Future<void> loginWithApple() async {
    // 애플 로그인 구현 예제
  }

  Future<void> loginWithGoogle() async {
    // 구글 로그인 구현 예제
  }

  Future<bool> loginWithNaver() async {
    // 네이버 로그인 구현 예제
    try {
      print('네이버 로그인 시도');
      final NaverLoginResult res = await FlutterNaverLogin.logIn();
      NaverToken naverToken = await FlutterNaverLogin.getCurrentAccessToken();
      if (res.status == NaverLoginStatus.loggedIn) {
        print('네이버 로그인 성공');
        bool result = await loginWithSocialToken(
          'NAVER',
          naverToken.accessToken,
          naverToken.refreshToken,
        );
        if (result) {
          print('FROM NAVER TO 자체 토큰 발급 성공');
          // 네이버 로그아웃 처리
          NaverLoginResult logoutRes =
              await FlutterNaverLogin.logOutAndDeleteToken();
          if (logoutRes.status == NaverLoginStatus.loggedOut) {
            return true;
          }
        } else {
          print('FROM NAVER TO 자체 토큰 발급 실패');
          return false;
        }
      } else {
        print('네이버 로그인 실패');
        return false;
      }
      return false;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  // 로컬 서버에 Token 전달하여 자체 토큰 발급
  Future<bool> loginWithSocialToken(
    String type,
    String token,
    String refreshToken,
  ) async {
    // 로컬 서버에 idToken 전달하여 자체 토큰 발급
    print('[$type]\nToken: $token \nrefreshToken: $refreshToken');
    //localhost:8080/api/login

    // request body
    // type : KAKAO, GOOGLE, NAVER
    // token : 토큰값

    final response = await http.post(
      Uri.parse('http://$baseUrl/api/login'),
      body: {'type': type, 'token': token, 'refreshToken': refreshToken},
    );
    if (response.statusCode == 200) {
      print('response: ${response.body}');
      // TODO: 발급받은 토큰을 SharedPreferences에 저장

      return true;
    } else {
      print('response: ${response.body}');

      return false;
    }
  }
}
