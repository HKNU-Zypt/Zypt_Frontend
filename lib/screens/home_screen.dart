import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:focused_study_time_tracker/screens/focus_time_screen.dart';
import 'package:focused_study_time_tracker/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

var weekdays = ['월', '화', '수', '목', '금', '토', '일'];

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 사용자 정보 섹션
                Container(
                  padding: const EdgeInsets.all(16),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${now.year}.${now.month}.${now.day} (${weekdays[now.weekday - 1]})",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 메인 콘텐츠
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.go('/focus-v2');
                          },

                          child: FractionallySizedBox(
                            widthFactor: 0.7, // 부모의 너비의 70%
                            child: Image.asset(
                              'assets/images/focusStartButton.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
