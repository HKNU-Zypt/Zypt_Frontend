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
        title: Text("서비스 약관"),
        leading: IconButton(
          onPressed: () {
            context.go('/mypage');
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      child: Center(child: Column(children: [Text("서비스 약관 내용이 들어갈 예정")])),
    );
  }
}
