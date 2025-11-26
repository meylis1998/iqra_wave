import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iqra_wave/core/routes/route_names.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_state.dart';
import 'package:iqra_wave/features/auth/presentation/pages/auth_status_page.dart';
import 'package:iqra_wave/features/auth/presentation/pages/login_page.dart';
import 'package:iqra_wave/features/home/presentation/pages/home_page.dart';
import 'package:iqra_wave/features/splash/presentation/pages/splash_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static late final AuthBloc _authBloc;

  static void initialize(AuthBloc authBloc) {
    _authBloc = authBloc;
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    redirect: (context, state) {
      final authState = _authBloc.state;
      final isOnSplash = state.matchedLocation == RouteNames.splash;
      final isOnLogin = state.matchedLocation == RouteNames.login;
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoading = authState is AuthLoading ||
          authState is AuthInitial ||
          authState is AuthRefreshing;

      // Allow splash page during initialization
      if (isLoading && isOnSplash) {
        return null;
      }

      // If authenticated and on login/splash, go to home
      if (isAuthenticated && (isOnLogin || isOnSplash)) {
        return RouteNames.home;
      }

      // If not authenticated and not loading, redirect to login
      if (!isAuthenticated && !isLoading && !isOnLogin) {
        return RouteNames.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SplashPage()),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginPage()),
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

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
