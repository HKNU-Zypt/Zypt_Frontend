import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/bottom_navigation_bar.dart';

class NavigationLayout extends StatelessWidget {
  const NavigationLayout({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
