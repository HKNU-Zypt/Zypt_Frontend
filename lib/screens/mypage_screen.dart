import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/services/login.dart';
import 'package:go_router/go_router.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  void _logout() async {
    await LoginService().logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
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
            ElevatedButton(onPressed: _logout, child: const Text('로그아웃')),
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
