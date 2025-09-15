import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/bottom_navigation_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:focused_study_time_tracker/actions/streaming_actions.dart';

class NavigationLayout extends StatelessWidget {
  const NavigationLayout({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final String path = GoRouterState.of(context).uri.path;
    final Widget fab = () {
      switch (path) {
        case '/streaming':
          return FloatingActionButton(
            onPressed: () => StreamingActions.createRoomFlow(context),
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 36),
          );
        case '/home':
        case '/statistics':
        case '/mypage':
        default:
          return FloatingActionButton(
            onPressed: () {
              context.go('/focus-v2');
            },
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
          );
      }
    }();

    return Scaffold(
      body: SafeArea(child: child),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: fab,
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
