import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:focused_study_time_tracker/services/login.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 로그인 버튼
            ElevatedButton(
              onPressed: () {
                LoginService().loginWithKakao().then((value) {
                  if (value) {
                    print('[LoginScreen] 카카오 로그인 성공');
                    context.go('/home');
                  }
                });
              },
              child: const Text('카카오 로그인'),
            ),
            ElevatedButton(
              onPressed: () {
                LoginService().loginWithNaver().then((value) {
                  if (value) {
                    print('[LoginScreen] 네이버 로그인 성공');
                    context.go('/home');
                  }
                });
              },
              child: const Text('네이버 로그인'),
            ),
            ElevatedButton(
              onPressed: () {
                LoginService().loginWithGoogle().then((value) {
                  if (value) {
                    print('[LoginScreen] 구글 로그인 성공');
                    context.go('/home');
                  }
                });
              },
              child: const Text('구글 로그인'),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/home');
              },
              child: const Text('홈으로 이동'),
            ),
            ElevatedButton(
              onPressed: () {
                LoginService().getAccessToken().then((value) {
                  print('[LoginScreen] zypt 액세스 토큰: $value');
                  LoginService().getRefreshToken().then((value) {
                    print('[LoginScreen] zypt 리프레시 토큰: $value');
                  });
                });
              },
              child: const Text('zypt token 확인'),
            ),
          ],
        ),
      ),
    );
  }
}
