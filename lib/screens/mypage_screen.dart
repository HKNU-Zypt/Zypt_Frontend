import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/services/login.dart';
import 'package:focused_study_time_tracker/services/user_service.dart';
import 'package:go_router/go_router.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
    final loginService = LoginService();

    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'My Page Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await loginService.logout();
                if (result) {
                  context.go('/login');
                }
              },
              child: const Text('로그아웃'),
            ),
            ElevatedButton(
              onPressed: () {
                loginService.getAccessToken().then((value) {
                  print('[LoginScreen] zypt 액세스 토큰: $value');
                  loginService.getRefreshToken().then((value) {
                    print('[LoginScreen] zypt 리프레시 토큰: $value');
                  });
                });
              },
              child: const Text('zypt token 확인'),
            ),
            ElevatedButton(
              onPressed: () {
                loginService.refreshAccessToken().then((value) {
                  print('[LoginScreen] 토큰 갱신 결과: $value');
                });
              },
              child: const Text('토큰 갱신'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await loginService.withdraw();
                if (result) {
                  context.go('/login');
                }
              },
              child: const Text('회원탈퇴'),
            ),
            // 로그인 페이지 이동
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('로그인 페이지 이동'),
            ),
            ElevatedButton(
              onPressed: () {
                UserService().updateNickname('zypt');
              },
              child: const Text('닉네임 업데이트'),
            ),
          ],
        ),
      ),
    );
  }
}
