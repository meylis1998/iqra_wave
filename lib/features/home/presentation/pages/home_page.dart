import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:iqra_wave/core/routes/route_names.dart';
import 'package:iqra_wave/core/theme/app_theme.dart';
import 'package:iqra_wave/core/theme/theme_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
      appBar: AppBar(
        title: const Text('IqraWave'),
        actions: [
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

                      // Determine the target theme BEFORE toggling
                      final newTheme = themeCubit.state == ThemeMode.dark
                          ? AppTheme.lightTheme
                          : AppTheme.darkTheme;

                      // Trigger animation with new theme and reverse option
                      ThemeSwitcher.of(context).changeTheme(
                        theme: newTheme,
                        isReversed: themeCubit.state == ThemeMode.light,
                      );

                      // Update cubit state
                      themeCubit.toggleTheme();
                    },
                  );
                },
              );
            },
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
              ElevatedButton.icon(
                onPressed: () => context.go(RouteNames.posts),
                icon: const Icon(Icons.article),
                label: const Text('View Posts Example'),
              ),
            ],
          ),
        ),
      ),
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
