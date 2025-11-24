import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iqra_wave/core/routes/route_names.dart';
import 'package:iqra_wave/core/theme/app_theme.dart';
import 'package:iqra_wave/core/theme/theme_cubit.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_event.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IqraWave'),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    state is AuthAuthenticated
                        ? Icons.verified_user
                        : Icons.error_outline,
                    color: state is AuthAuthenticated
                        ? Colors.green
                        : Colors.orange,
                  ),
                  tooltip: state is AuthAuthenticated
                      ? 'Authenticated'
                      : 'Not Authenticated',
                  onPressed: () {
                    context.push(RouteNames.authStatus);
                  },
                );
              },
            ),

            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return ThemeSwitcher(
                  builder: (context) {
                    return IconButton(
                      icon: Icon(
                        themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: () {
                        final themeCubit = context.read<ThemeCubit>();

                        final newTheme = themeCubit.state == ThemeMode.dark
                            ? AppTheme.lightTheme
                            : AppTheme.darkTheme;

                        ThemeSwitcher.of(context).changeTheme(
                          theme: newTheme,
                          isReversed: themeCubit.state == ThemeMode.light,
                        );

                        themeCubit.toggleTheme();
                      },
                    );
                  },
                );
              },
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'auth_status') {
                  context.push(RouteNames.authStatus);
                } else if (value == 'logout') {
                  _showLogoutDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'auth_status',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings),
                      SizedBox(width: 8),
                      Text('Auth Status'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Clear Auth Data',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to IqraWave',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'A production-ready Flutter starter template with Clean Architecture and BLoC pattern',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                const _FeatureCard(
                  icon: Icons.architecture,
                  title: 'Clean Architecture',
                  description: 'Separation of concerns with proper layers',
                ),
                const SizedBox(height: 16),
                const _FeatureCard(
                  icon: Icons.widgets,
                  title: 'BLoC Pattern',
                  description: 'Reactive state management solution',
                ),
                const SizedBox(height: 16),
                const _FeatureCard(
                  icon: Icons.api,
                  title: 'API Integration',
                  description: 'Dio with interceptors and error handling',
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.push(RouteNames.authStatus),
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Auth Status'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.go(RouteNames.posts),
                      icon: const Icon(Icons.article),
                      label: const Text('Posts'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Auth Data'),
        content: const Text(
          'This will clear your authentication tokens. '
          'The app will re-authenticate automatically on next startup.\n\n'
          'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.read<AuthBloc>().add(const AuthLogout());

              Future.delayed(const Duration(milliseconds: 300), () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Auth data cleared. Restart app to re-authenticate.',
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              });
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(description),
      ),
    );
  }
}
