import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/mock_data.dart';
import 'screens/login_screen.dart';
import 'screens/plant_details_screen.dart';
import 'screens/plant_form_screen.dart';
import 'screens/plants_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/watering_log_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final id = state.pathParameters['id'];
    if (id != null && !mockPlants.any((plant) => plant.id == id)) {
      return '/plants';
    }
    return null;
  },
  errorBuilder: (context, state) => const _RouteErrorScreen(),
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/plants',
      builder: (context, state) => const PlantsScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const PlantFormScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              PlantDetailsScreen(id: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) =>
                  PlantFormScreen(plantId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'watering',
              builder: (context, state) =>
                  WateringLogScreen(plantId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'reminders',
              builder: (context, state) =>
                  RemindersScreen(plantId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/watering-log',
      builder: (context, state) => const WateringLogScreen(),
    ),
    GoRoute(
      path: '/reminders',
      builder: (context, state) => const RemindersScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Страница не найдена')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/plants'),
          child: const Text('К моим растениям'),
        ),
      ),
    );
  }
}
