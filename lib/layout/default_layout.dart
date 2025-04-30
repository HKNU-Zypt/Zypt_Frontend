// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  DefaultLayout({super.key, this.appBar, required this.child});

  AppBar? appBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: child), appBar: appBar);
  }
}
