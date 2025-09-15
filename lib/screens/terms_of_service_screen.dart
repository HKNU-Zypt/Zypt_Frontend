import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:go_router/go_router.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      appBar: AppBar(
        title: Text(
          "서비스 약관",
          style: TextStyle(
            fontFamily: 'SOYO Maple Bold',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.go('/mypage');
          },
          // 1. 내부 여백을 제거합니다.
          padding: EdgeInsets.zero,
          // 2. 정렬을 중앙으로 명시합니다.
          alignment: Alignment.center,
          icon: Icon(
            Icons.arrow_left_rounded,
            color: Color(0xFFF95C3B),
            size: 60,
          ),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              "서비스 약관 내용이 들어갈 예정",
              style: TextStyle(fontFamily: 'SOYO Maple Regular'),
            ),
          ],
        ),
      ),
    );
  }
}
