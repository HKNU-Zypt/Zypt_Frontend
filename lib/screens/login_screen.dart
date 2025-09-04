import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 브랜드 로고
              SvgPicture.asset('assets/images/zypt_logo.svg', width: 200),
              const SizedBox(height: 165),
              // 소셜 로그인 버튼들 (피그마 스타일의 SVG 버튼)
              _SocialLoginButton(
                assetPath: 'assets/images/kakao_login.svg',
                semanticsLabel: '카카오로 시작하기',
                onTap: () {
                  LoginService().loginWithKakao().then((ok) {
                    if (ok) context.go('/nickname');
                  });
                },
              ),
              const SizedBox(height: 20),
              _SocialLoginButton(
                assetPath: 'assets/images/naver_login.svg',
                semanticsLabel: '네이버로 시작하기',
                onTap: () {
                  LoginService().loginWithNaver().then((ok) {
                    if (ok) context.go('/nickname');
                  });
                },
              ),
              const SizedBox(height: 20),
              _SocialLoginButton(
                assetPath: 'assets/images/google_login.svg',
                semanticsLabel: '구글로 시작하기',
                onTap: () {
                  LoginService().loginWithGoogle().then((ok) {
                    if (ok) context.go('/nickname');
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String assetPath;
  final String? semanticsLabel;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.assetPath,
    required this.onTap,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            height: 56,
            fit: BoxFit.contain,
            semanticsLabel: semanticsLabel,
          ),
        ),
      ),
    );
  }
}
