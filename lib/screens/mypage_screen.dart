import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/services/login.dart';
import 'package:focused_study_time_tracker/services/user_service.dart';
import 'package:focused_study_time_tracker/components/main_button.dart';
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
            SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MainButton.small(
                  title: '로그아웃',
                  onPressed: () async {
                    final result = await loginService.logout();
                    if (result) {
                      context.go('/login');
                    }
                  },
                ),
                SizedBox(width: 12),
                MainButton.small(
                  title: '토큰 갱신',
                  onPressed: () {
                    loginService.refreshAccessToken().then((value) {
                      print('[LoginScreen] 토큰 갱신 결과: $value');
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            MainButton.large(
              title: 'zypt token 확인',
              onPressed: () {
                loginService.getAccessToken().then((value) {
                  print('[LoginScreen] zypt 액세스 토큰: $value');
                  loginService.getRefreshToken().then((value) {
                    print('[LoginScreen] zypt 리프레시 토큰: $value');
                  });
                });
              },
            ),
            SizedBox(height: 12),
            MainButton.large(
              title: '회원탈퇴',
              onPressed: () async {
                final result = await loginService.withdraw();
                if (result) {
                  context.go('/login');
                }
              },
            ),
            SizedBox(height: 12),
            // 로그인 페이지 이동
            MainButton(
              title: '로그인 페이지 이동',
              onPressed: () {
                context.go('/login');
              },
            ),
            SizedBox(height: 12),
            MainButton.medium(
              title: '닉네임 업데이트',
              onPressed: () {
                UserService().updateNickname('zypt');
              },
            ),
          ],
        ),
      ),
    );
  }
}
