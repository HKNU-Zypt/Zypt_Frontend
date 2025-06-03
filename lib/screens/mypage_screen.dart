import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/const.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  void _logoutWithKakao() async {
    try {
      await UserApi.instance.logout();
      print('로그아웃 성공, SDK에서 토큰 폐기');
    } catch (error) {
      print('로그아웃 실패, SDK에서 토큰 폐기 $error');
    } finally {
      setState(() {
        token = null;
      });
      context.go('/login');
    }
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
            ElevatedButton(
              onPressed: _logoutWithKakao,
              child: const Text('카카오톡으로 로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}
