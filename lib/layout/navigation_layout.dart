import 'package:flutter/material.dart';
import 'package:focused_study_time_tracker/components/bottom_navigation_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:focused_study_time_tracker/actions/streaming_actions.dart';

class NavigationLayout extends StatelessWidget {
  const NavigationLayout({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  Widget build(BuildContext context) {
    final String path = GoRouterState.of(context).uri.path;

    // result 화면에서는 네비게이션 바와 FAB 숨김
    final bool hideNavigation = path == '/result';

    final Widget? fab =
        hideNavigation
            ? null
            : () {
              switch (path) {
                case '/streaming':
                  return FloatingActionButton(
                    onPressed: () => StreamingActions.createRoomFlow(context),
                    backgroundColor: Colors.black,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add, color: Colors.white, size: 36),
                  );
                case '/statistics':
                  return FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (ctx) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: Stack(
                              children: [
                                // Main card
                                Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    24,
                                    20,
                                    20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '각 색상의 상태',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            width: 18,
                                            height: 18,
                                            color: const Color(0xFF6BAB93),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text('집중 상태(FOCUS)'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            width: 18,
                                            height: 18,
                                            color: const Color(0xFFF95C3B),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text('집중하지 않음 (DISTRACTED)'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Container(
                                            width: 18,
                                            height: 18,
                                            color: const Color(0xFFE6E5D3),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text('졸음 (SLEEP) - 졸음 구간'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(),
                                        child: const Text('닫기'),
                                      ),
                                    ],
                                  ),
                                ),
                                // Close (X) button at top-right
                              ],
                            ),
                          );
                        },
                      );
                    },
                    backgroundColor: Colors.black,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                case '/home':
                case '/mypage':
                default:
                  return FloatingActionButton(
                    onPressed: () {
                      context.go('/focus-v2');
                    },
                    backgroundColor: Colors.black,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  );
              }
            }();

    return Scaffold(
      body: SafeArea(child: navigationShell),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: fab,
      bottomNavigationBar:
          hideNavigation
              ? null
              : CustomBottomNavigationBar(navigationShell: navigationShell),
    );
  }
}
