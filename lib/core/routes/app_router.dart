import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iqra_wave/core/routes/route_names.dart';
import 'package:iqra_wave/features/auth/presentation/pages/auth_status_page.dart';
import 'package:iqra_wave/features/home/presentation/pages/home_page.dart';
import 'package:iqra_wave/features/splash/presentation/pages/splash_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SplashPage()),
      ),
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const HomePage()),
      ),
      GoRoute(
        path: RouteNames.authStatus,
        name: RouteNames.authStatus,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const AuthStatusPage()),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}
