import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/bottom_navigation_bar.dart';
import 'package:go_router/go_router.dart';

class NavigationLayout extends StatelessWidget {
  const NavigationLayout({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/focus');
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
