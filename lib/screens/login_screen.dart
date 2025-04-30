import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_study_time_tracker/const.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _loginWithKakao() async {
    // 카카오 로그인 구현 예제

    // 카카오톡 실행 가능 여부 확인
    // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공 : ${token!.accessToken}');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          token = await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공 : ${token!.accessToken}');
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
      }
    }
    setState(() {});
    if (token != null) {
      print('로그인 성공, 토큰: ${token!.accessToken}');
      // 2초 후 홈 화면으로 이동
      await Future.delayed(const Duration(seconds: 2));
      context.go('/home');
    } else {
      print('로그인 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'idToken: ${token?.idToken.toString().substring(0, 6) ?? '토큰 없음'}',
            ),
            Text(
              'accessToken: ${token?.accessToken.toString().substring(0, 6) ?? '토큰 없음'}',
            ),
            Text(
              'refreshToken: ${token?.refreshToken.toString().substring(0, 6) ?? '토큰 없음'}',
            ),
            Text(
              'refreshTokenExpiresAt: ${token?.refreshTokenExpiresAt.toString() ?? '토큰 없음'}',
            ),
            Text('expiresAt: ${token?.expiresAt.toString() ?? '토큰 없음'}'),
            Text('scopes: ${token?.scopes.toString() ?? '토큰 없음'}'),
            // 로그인 버튼
            ElevatedButton(
              onPressed: _loginWithKakao,
              child: const Text('카카오톡으로 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> printKeyHash() async {
  try {
    final keyHash = await KakaoSdk.origin;
    print("현재 사용 중인 키 해시: $keyHash");
  } catch (e) {
    print("키 해시를 가져오는 중 오류 발생: $e");
  }
}
