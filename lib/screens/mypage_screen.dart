import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/box_design.dart';
import 'package:focused_study_time_tracker/models/user.dart';
import 'package:focused_study_time_tracker/services/login.dart';
import 'package:focused_study_time_tracker/services/user_service.dart';
import 'package:focused_study_time_tracker/components/main_button.dart';
import 'package:go_router/go_router.dart';
import 'package:focused_study_time_tracker/components/form_dialog.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final loginService = LoginService();
  final userService = UserService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = userService.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  '프로필',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SoyoMaple',
                  ),
                ),
                SizedBox(height: 30),
                BoxDesign(
                  backgroundcolor: Colors.white,
                  designcolor: Color(0xFF6BAB93),
                  width: 320,
                  height: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _user?.nickName ?? '오류가 발생했습니다.',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'SoyoMaple',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                _user?.email ?? '오류가 발생했습니다.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      // 닉네임 변경 아이콘 버튼
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final newNickname = await showNicknameDialog(
                                context,
                              );
                              if (newNickname != null &&
                                  newNickname.isNotEmpty) {
                                final updated = await userService
                                    .updateNickname(newNickname);
                                if (updated && mounted) {
                                  setState(() {
                                    _user = userService.currentUser;
                                  });
                                  print('zypt [MyPageScreen] 닉네임 업데이트 성공');
                                } else {
                                  print('zypt [MyPageScreen] 닉네임 업데이트 실패');
                                }
                              }
                            },
                            icon: Icon(Icons.edit_outlined, size: 17),
                          ),
                        ],
                      ),
                      Spacer(),
                      // 프로필 사진 부분
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                color: Colors.white,
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.face, size: 35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 프로필 박스
                SizedBox(height: 30),
                MainButton.medium(
                  title: '로그아웃',
                  onPressed: () async {
                    final result = await loginService.logout();
                    if (result) {
                      context.go('/login');
                    }
                  },
                ),
                SizedBox(height: 16),
                MainButton.medium(
                  title: '회원탈퇴',
                  onPressed: () async {
                    final result = await loginService.withdraw();
                    if (result) {
                      context.go('/login');
                    }
                  },
                ),
                SizedBox(height: 12),
                MainButton.medium(
                  title: '오픈소스 정보',
                  onPressed: () async {
                    context.go('/opensource');
                  },
                ),
                SizedBox(height: 12),
                MainButton.medium(
                  title: '서비스 약관',
                  onPressed: () async {
                    context.go('/terms');
                  },
                ),
                SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> showNicknameDialog(BuildContext context) async {
  final initial = UserService().currentUser?.nickName;
  final result = await showFormDialog(
    context,
    title: '닉네임 변경',
    fields: [
      FormDialogFieldConfig(
        id: 'nickname',
        hintText: '닉네임',
        initialValue: initial,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '닉네임을 입력하세요';
          }
          return null;
        },
      ),
    ],
    primaryButtonText: '변경사항 저장',
  );
  return result?['nickname'];
}
