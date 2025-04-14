import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black, // 선택된 아이템 색상
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      currentIndex: _getIdx(context),
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
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.center_focus_strong_sharp),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.area_chart_outlined),
          label: '통계',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.missed_video_call),
          label: '스트리밍',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
      ],
    );
  }
}
