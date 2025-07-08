import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  Future<bool> loginWithGoogle() async {
    // 구글 로그인 구현 예제
    try {
      // print('구글 로그인 초기화');
      GoogleSignIn.instance.initialize(
        serverClientId:
            "880578430112-3dg028mvc6jn0rsmplc7ln1rfe2bc072.apps.googleusercontent.com",
      );

      // print('구글 로그인 시도');
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      // 구글 액세스 토큰 발급을 위한 코드
      // final GoogleSignInClientAuthorization? clientAuth = await googleUser
      //     .authorizationClient
      //     .authorizationForScopes(['email', 'profile']);
      // print('구글 accessToken: ${clientAuth?.accessToken}');

      if (googleUser.authentication.idToken != null) {
        final idToken = googleUser.authentication.idToken;
        print('구글 idToken: ${googleUser.authentication.idToken}');
        bool result = await loginWithSocialToken('GOOGLE', idToken!, null);
        if (result) {
          print('FROM GOOGLE TO 자체 토큰 발급 성공');
          return true;
        } else {
          print('FROM GOOGLE TO 자체 토큰 발급 실패');
          return false;
        }
      } else {
        print('구글 로그인 실패');
        return false;
      }
    } catch (error) {
      print(error.toString());
      return false;
    }
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
    String? refreshToken,
  ) async {
    // 로컬 서버에 idToken 전달하여 자체 토큰 발급
    print('[$type]\nToken: $token \nrefreshToken: $refreshToken');
    //localhost:8080/api/login

    // request body
    // type : KAKAO, GOOGLE, NAVER
    // token : 토큰값

    final response = await http.post(
      Uri.parse('http://$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'type': type,
        'token': token,
        // refreshToken이 null이나 빈 문자열이 아닌 경우에만 추가
        if (refreshToken != null && refreshToken.isNotEmpty)
          'refreshToken': refreshToken,
      }),
    );
    if (response.statusCode == 200) {
      print('response: ${response.body}');
      print('response: ${response.headers}');
      String zyptRefreshToken = '';
      final setCookie = response.headers['set-cookie'] ?? '';
      final regExp = RegExp(r'refreshToken=([^;]+)');
      final match = regExp.firstMatch(setCookie);
      if (match != null) {
        zyptRefreshToken = match.group(1) ?? '';
      }
      String zyptAccessToken = response.headers['authorization'] ?? '';

      print('zyptRefreshToken: $zyptRefreshToken');
      print('zyptAccessToken: $zyptAccessToken');

      // 발급받은 토큰을 SharedPreferences에 저장
      await _saveTokens(zyptAccessToken, zyptRefreshToken);

      return true;
    } else {
      print('response: ${response.body}');

      return false;
    }
  }

  // 토큰을 SharedPreferences에 저장
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    print('토큰이 저장되었습니다.');
  }

  // 저장된 액세스 토큰 가져오기
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // 저장된 리프레시 토큰 가져오기
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  // 로그인 상태 확인 (토큰이 존재하는지)
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // 로그아웃 (토큰 삭제)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    print('로그아웃되었습니다.');
  }
}
