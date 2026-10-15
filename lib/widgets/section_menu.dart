import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SectionMenu extends StatelessWidget {
  const SectionMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Разделы',
      icon: const Icon(Icons.menu_rounded),
      onSelected: (location) => context.go(location),
      itemBuilder: (context) => const [
        PopupMenuItem(value: '/plants', child: Text('Мои растения')),
        PopupMenuItem(value: '/watering-log', child: Text('Журнал полива')),
        PopupMenuItem(value: '/reminders', child: Text('Напоминания')),
        PopupMenuItem(value: '/profile', child: Text('Мой профиль')),
      ],
    );
  }
}
