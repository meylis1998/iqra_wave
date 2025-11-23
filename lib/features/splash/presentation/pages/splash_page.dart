import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iqra_wave/core/routes/route_names.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_event.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timeoutTimer;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _startAuthTimeout();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startAuthTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _timedOut = true;
        });
      }
    });
  }

  void _navigateToHome() {
    if (mounted) {
      _timeoutTimer?.cancel();
      context.go(RouteNames.home);
    }
  }

  void _retryAuth() {
    setState(() {
      _timedOut = false;
    });
    _timeoutTimer?.cancel();
    _startAuthTimeout();
    context.read<AuthBloc>().add(const AuthInitialize());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _navigateToHome();
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flutter_dash,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'IqraWave',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quran Study Companion',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 48),

                  _buildStatusWidget(context, state),

                  const SizedBox(height: 24),

                  if (state is AuthError || _timedOut)
                    ElevatedButton.icon(
                      onPressed: _retryAuth,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context, AuthState state) {
    if (_timedOut) {
      return Column(
        children: [
          Icon(
            Icons.timer_off,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Authentication is taking longer than expected',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    if (state is AuthError) {
      return Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Authentication Failed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    if (state is AuthLoading ||
        state is AuthInitial ||
        state is AuthRefreshing) {
      return Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Authenticating...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    return Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Authenticated',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
