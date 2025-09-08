import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/box_design.dart';
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

    // 닉네임 수정 버튼을 눌렀을 때 팝업 창이 나오게 하는 함수.
    void showNicknameDialog() {
      final TextEditingController controller = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // 다이얼로그 모서리를 둥글게 설정
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Stack(
              alignment: Alignment.center,
              children: [
                // 1. 중앙 정렬된 제목 텍스트
                const Text(
                  '닉네임 변경',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // 2. 오른쪽 정렬된 X 아이콘 버튼
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      // 버튼을 누르면 팝업창을 닫습니다.
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '새 닉네임을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            actions: <Widget>[
              // 버튼을 중앙에 꽉 채워서 배치
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('변경사항 저장'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
            // actions 위젯 주변의 기본 여백 제거
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          );
        },
      );
    }

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
                  '마이페이지',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                BoxDesign(
                  backgroundcolor: Colors.white,
                  designcolor: Color(0xFFD9D9D9),
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
                                "나는야똑똑이",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "abcdabcd@naver.com",
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
                            onPressed: () {
                              showNicknameDialog();
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
