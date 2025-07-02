import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/const.dart';
import 'package:go_router/go_router.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  void _logoutWithKakao() async {
    setState(() {
      token = null;
    });
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
            ElevatedButton(
              onPressed: _logoutWithKakao,
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}
