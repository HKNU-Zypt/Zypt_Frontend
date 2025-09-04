import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/layout/default_layout.dart';
import 'package:go_router/go_router.dart';

class OpenSourceInfoScreen extends StatefulWidget {
  const OpenSourceInfoScreen({super.key});

  @override
  State<OpenSourceInfoScreen> createState() => _OpenSourceInfoScreenState();
}

class _OpenSourceInfoScreenState extends State<OpenSourceInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      appBar: AppBar(
        title: Text("오픈소스 정보"),
        leading: IconButton(
          onPressed: () {
            context.go('/mypage');
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      child: Center(child: Column(children: [Text("오픈소스 내용이 들어갈 예정")])),
    );
  }
}
