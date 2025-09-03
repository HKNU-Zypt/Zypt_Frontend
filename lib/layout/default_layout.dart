// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  const DefaultLayout({super.key, this.appBar, required this.child});

  final AppBar? appBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      appBar: appBar,
      backgroundColor: Color(0xffc7c7c7),
    );
  }
}
