import 'dart:async';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/configs/secrets_manager.dart';
import 'package:iqra_wave/core/di/injection_container.dart';
import 'package:iqra_wave/core/routes/app_router.dart';
import 'package:iqra_wave/core/services/token_refresh_scheduler.dart';
import 'package:iqra_wave/core/theme/app_theme.dart';
import 'package:iqra_wave/core/theme/theme_cubit.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_event.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final secretsManager = SecretsManager();
      await secretsManager.initialize();

      AppConfig.initialize(secretsManager);

      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory(
          (await getTemporaryDirectory()).path,
        ),
      );

      final sharedPreferences = await SharedPreferences.getInstance();
      getIt
        ..registerLazySingleton(() => sharedPreferences)
        ..registerLazySingleton(() => const FlutterSecureStorage())
        ..registerLazySingleton(() => secretsManager);

      await configureDependencies();

      final sentryDsn = AppConfig.sentryDsn;
      if (sentryDsn != null && sentryDsn.isNotEmpty) {
        await SentryFlutter.init(
          (options) {
            options
              ..dsn = sentryDsn
              ..environment = AppConfig.environment.name
              ..tracesSampleRate = AppConfig.environment == Environment.prod
                  ? 0.2
                  : 1.0
              ..enableAutoSessionTracking = true
              ..attachStacktrace = true
              ..enableAutoPerformanceTracing = true
              ..debug = AppConfig.environment == Environment.dev;

            AppLogger.info('Sentry initialized');
          },
          appRunner: () => runApp(const MyApp()),
        );
      } else {
        AppLogger.info(
          'Sentry not configured - running without error tracking',
        );
        runApp(const MyApp());
      }
    },
    (error, stack) {
      AppLogger.fatal('Unhandled error', error, stack);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ThemeCubit>(),
        ),
        BlocProvider(
          create: (context) {
            final bloc = getIt<AuthBloc>();

            bloc.stream.listen((state) {
              if (state is AuthAuthenticated) {
                getIt<TokenRefreshScheduler>().startProactiveRefresh();
              } else if (state is AuthUnauthenticated) {
                getIt<TokenRefreshScheduler>().stopProactiveRefresh();
              }
            });

            bloc.add(const AuthInitialize());

            return bloc;
          },
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final messenger = ScaffoldMessenger.maybeOf(context);
              if (messenger != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getErrorMessage(state.message),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red.shade700,
                    action: SnackBarAction(
                      label: 'Dismiss',
                      textColor: Colors.white,
                      onPressed: messenger.hideCurrentSnackBar,
                    ),
                  ),
                );
              }
            });
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final theme = themeMode == ThemeMode.dark
                ? AppTheme.darkTheme
                : AppTheme.lightTheme;

            return ThemeProvider(
              initTheme: theme,
              duration: const Duration(milliseconds: 400),
              builder: (_, myTheme) {
                return MaterialApp.router(
                  title: AppConfig.appName,
                  debugShowCheckedModeBanner: false,
                  theme: myTheme,
                  routerConfig: AppRouter.router,
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _getErrorMessage(String technicalMessage) {
    if (technicalMessage.toLowerCase().contains('network') ||
        technicalMessage.toLowerCase().contains('internet')) {
      return 'No internet connection. Please check your network.';
    }
    if (technicalMessage.toLowerCase().contains('oauth') ||
        technicalMessage.toLowerCase().contains('authentication')) {
      return 'Authentication service unavailable. Please try again.';
    }
    if (technicalMessage.toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (technicalMessage.toLowerCase().contains('server')) {
      return 'Server error. Please try again later.';
    }
    return 'Authentication error occurred';
  }
}
