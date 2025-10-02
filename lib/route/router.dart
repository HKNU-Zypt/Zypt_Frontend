import 'package:focused_study_time_tracker/layout/navigation_layout.dart';
import 'package:focused_study_time_tracker/models/focus_time.dart';
import 'package:focused_study_time_tracker/screens/focus_time_result_screen.dart';
import 'package:focused_study_time_tracker/screens/focus_time_screen.dart';
import 'package:focused_study_time_tracker/screens/focus_time_screenV2.dart';
import 'package:focused_study_time_tracker/screens/home_screen.dart';
import 'package:focused_study_time_tracker/screens/focus_time_test_screen.dart';
import 'package:focused_study_time_tracker/screens/login_screen.dart';
import 'package:focused_study_time_tracker/screens/mypage_screen.dart';
import 'package:focused_study_time_tracker/screens/nick_name_screen.dart';
import 'package:focused_study_time_tracker/screens/open_source_info_screen.dart';
import 'package:focused_study_time_tracker/screens/statistics_screenV2.dart';
import 'package:focused_study_time_tracker/screens/streaming_join_screen.dart';
import 'package:focused_study_time_tracker/screens/streaming_screen.dart';
import 'package:focused_study_time_tracker/screens/terms_of_service_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:focused_study_time_tracker/services/login.dart';
import 'package:focused_study_time_tracker/services/user_service.dart';

final router = GoRouter(
  initialLocation: '/home',
  debugLogDiagnostics: true,
  redirect: (context, state) async {
    final String currentPath = state.uri.path;
    final bool loggedIn = await LoginService().isLoggedIn();

    if (!loggedIn && currentPath != '/login') {
      return '/login';
    }

    // 닉네임 페이지 진입 시에만 검증
    if (loggedIn && currentPath == '/nickname') {
      final userService = UserService();
      final savedNickname = await userService.getNickname();

      // 닉네임이 이미 설정되어 있다면 홈으로 리다이렉트
      if (savedNickname != null) {
        final uuidPattern = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        );
        if (!uuidPattern.hasMatch(savedNickname)) {
          return '/home';
        }
      }
    }

    return null;
  },
  routes: [
    /// ShellRoute로 바텀 네비게이션이 있는 구조 정의
    ShellRoute(
      builder: (context, state, child) {
        return NavigationLayout(child: child); // 공통 UI: 하단 네비게이션 포함
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
        GoRoute(
          path: '/statistics',
          builder: (context, state) => StatisticsScreenv2(),
        ),
        GoRoute(
          path: '/streaming',
          builder: (context, state) => StreamingJoinScreen(),
        ),
        GoRoute(path: '/mypage', builder: (context, state) => MyPageScreen()),
        GoRoute(
          path: '/result',
          builder: (context, state) {
            final sessionData = state.extra as FocusTimeInsertDto;
            return FocusResultScreen(sessionData: sessionData);
          },
        ),
      ],
    ),

    // 로그인 같은 바텀네비 없는 화면은 ShellRoute 밖에 정의
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/nickname', builder: (context, state) => NickNameScreen()),
    GoRoute(
      path: '/focus-test',
      builder: (context, state) => const FocusTimeTestScreen(),
    ),
    GoRoute(path: '/focus', builder: (context, state) => FocusTimeScreen()),
    GoRoute(
      path: '/focus-v2',
      builder: (context, state) => FocusTimeScreenV2(),
    ),

    GoRoute(
      path: '/opensource',
      builder: (context, state) => OpenSourceInfoScreen(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => TermsOfServiceScreen(),
    ),
    // router.dart에 GoRoute 정의
    GoRoute(
      path: '/streaming_room',
      builder: (context, state) {
        final roomName = (state.extra as Map?)?['roomName'] as String? ?? '';
        final token = (state.extra as Map?)?['token'] as String? ?? '';
        return StreamingScreen(roomName: roomName, token: token);
      },
    ),
  ],
);
