import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'models/recording.dart';
import 'providers/auth_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/now_playing_screen.dart';
import 'screens/recording_screen.dart';
import 'screens/performance_report_screen.dart';
import 'screens/performance_results_screen.dart';
import 'screens/my_recordings_screen.dart';
import 'screens/liked_songs_screen.dart';
import 'screens/recently_played_screen.dart';
import 'screens/all_songs_screen.dart';
import 'widgets/app_shell.dart';
import 'theme/app_theme.dart';

/// App router configuration — matches NAVIGATION_FLOW.md hierarchy.
/// Uses ShellRoute for the tab shell (Home/Search/Library/Profile) with
/// MiniPlayer + BottomNavBar, and standalone routes for auth + overlays.

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ─── Root & Auth Flow ───
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final auth = context.read<AuthProvider>();
        return auth.isLoggedIn ? '/home' : '/welcome';
      },
    ),
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

    // ─── Tab Shell (with MiniPlayer + BottomNav) ───
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => _TabShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/library', builder: (_, __) => const LibraryScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/liked-songs', builder: (_, __) => const LikedSongsScreen()),
      ],
    ),

    // ─── Full-Screen Overlays (no shell) ───
    GoRoute(path: '/now-playing', builder: (_, __) => const NowPlayingScreen()),
    GoRoute(path: '/recording', builder: (_, __) => const RecordingScreen()),
    GoRoute(path: '/performance-report', builder: (_, state) {
      final recording = state.extra as Recording?;
      return PerformanceReportScreen(recording: recording);
    }),
    GoRoute(path: '/performance-results', builder: (_, __) => const PerformanceResultsScreen()),
    GoRoute(path: '/my-recordings', builder: (_, __) => const MyRecordingsScreen()),
    GoRoute(path: '/recently-played', builder: (_, __) => const RecentlyPlayedScreen()),
    GoRoute(path: '/all-songs', builder: (_, __) => const AllSongsScreen()),
  ],
);

/// Stateful tab shell that manages tab index and renders AppShell.
class _TabShell extends StatefulWidget {
  final Widget child;
  const _TabShell({required this.child});

  @override
  State<_TabShell> createState() => _TabShellState();
}

class _TabShellState extends State<_TabShell> {
  int _currentIndex = 0;

  static const _tabPaths = ['/home', '/search', '/library', '/profile'];

  @override
  void didUpdateWidget(covariant _TabShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIndex();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndex();
  }

  void _updateIndex() {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _tabPaths.indexWhere((p) => location.startsWith(p));
    if (idx != -1 && idx != _currentIndex) {
      setState(() => _currentIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: _currentIndex,
      onTabChanged: (index) {
        setState(() => _currentIndex = index);
        context.go(_tabPaths[index]);
      },
      onMiniPlayerTap: () => context.push('/now-playing'),
      child: widget.child,
    );
  }
}

/// Root MaterialApp widget.
class CadenceaApp extends StatelessWidget {
  const CadenceaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cadencea',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
