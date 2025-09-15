import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  _getIdx(BuildContext context) {
    if (GoRouterState.of(context).uri.toString() == '/home') {
      return 0;
    } else if (GoRouterState.of(context).uri.toString() == '/statistics') {
      return 1;
    } else if (GoRouterState.of(context).uri.toString() == '/streaming') {
      return 2;
    } else if (GoRouterState.of(context).uri.toString() == '/mypage') {
      return 3;
    }
    return 0; // 예외 처리
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _getIdx(context);

    final iconsInactive = <IconData>[
      Icons.center_focus_strong_sharp,
      Icons.area_chart_outlined,
      Icons.missed_video_call_outlined,
      Icons.person_outline,
    ];
    final iconsActive = <IconData>[
      Icons.center_focus_strong_sharp,
      Icons.area_chart,
      Icons.missed_video_call,
      Icons.person,
    ];
    final labels = <String>['Home', 'Statistics', 'Streaming', '마이페이지'];

    return Container(
      color: Colors.transparent,
      child: AnimatedBottomNavigationBar.builder(
        itemCount: labels.length,
        activeIndex: currentIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 24,
        rightCornerRadius: 24,
        backgroundColor: Colors.white,
        height: 72,
        elevation: 8,
        shadow: const Shadow(
          color: Color(0x14000000),
          blurRadius: 8,
          offset: Offset(0, -2),
        ),
        borderColor: Colors.black,
        borderWidth: 2,
        tabBuilder: (index, isActive) {
          final Color iconColor =
              isActive ? Colors.black : const Color(0xFF9CA3AF);
          final Color labelColor =
              isActive ? Colors.black : const Color(0xFF6B7280);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? iconsActive[index] : iconsInactive[index],
                color: iconColor,
              ),
              const SizedBox(height: 4),
              Text(
                labels[index],
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'AppleSDGothicNeo',
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: labelColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
        onTap: (value) {
          switch (value) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/statistics');
              break;
            case 2:
              context.go('/streaming');
              break;
            case 3:
              context.go('/mypage');
              break;
          }
        },
      ),
    );
  }
}
