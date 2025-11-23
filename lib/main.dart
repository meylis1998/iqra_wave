import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/di/injection_container.dart';
import 'package:iqra_wave/core/routes/app_router.dart';
import 'package:iqra_wave/core/theme/app_theme.dart';
import 'package:iqra_wave/core/theme/theme_cubit.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_event.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getTemporaryDirectory()).path,
    ),
  );

  AppConfig.setEnvironment(Environment.dev);

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt..registerLazySingleton(() => sharedPreferences)

  // Register FlutterSecureStorage
  ..registerLazySingleton(() => const FlutterSecureStorage());

  await configureDependencies();

  runApp(const MyApp());
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
          create: (context) => getIt<AuthBloc>()..add(const AuthInitialize()),
        ),
      ],
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
    );
  }
}
