import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/garden_model.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: navigationShell.goBranch,
      destinations: [
        NavigationDestination(
          icon: Consumer<GardenModel>(
            builder: (context, model, child) =>
                Badge(label: Text('${model.plants.length}'), child: child!),
            child: const Icon(Icons.eco_outlined),
          ),
          label: 'Растения',
        ),
        NavigationDestination(
          icon: Consumer<GardenModel>(
            builder: (context, model, child) =>
                Badge(label: Text('${model.waterings.length}'), child: child!),
            child: const Icon(Icons.water_drop_outlined),
          ),
          label: 'Журнал',
        ),
        const NavigationDestination(
          icon: Icon(Icons.notifications_none_rounded),
          label: 'Напоминания',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Профиль',
        ),
      ],
    ),
  );
}
