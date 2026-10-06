import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'plants_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _sections = <({IconData icon, String title, String subtitle})>[
    (
      icon: Icons.login_rounded,
      title: 'Вход и регистрация',
      subtitle: 'Ваш личный сад начинается здесь',
    ),
    (
      icon: Icons.local_florist_outlined,
      title: 'Мои растения',
      subtitle: 'Коллекция, поиск и статус полива',
    ),
    (
      icon: Icons.eco_outlined,
      title: 'Карточка растения',
      subtitle: 'Вид, фото и история ухода',
    ),
    (
      icon: Icons.add_circle_outline_rounded,
      title: 'Новое растение',
      subtitle: 'Название, вид и интервал полива',
    ),
    (
      icon: Icons.water_drop_outlined,
      title: 'Журнал полива',
      subtitle: 'Поливы и заметки о растениях',
    ),
    (
      icon: Icons.notifications_none_rounded,
      title: 'Напоминания',
      subtitle: 'План ухода и выполненные задачи',
    ),
    (
      icon: Icons.person_outline_rounded,
      title: 'Мой профиль',
      subtitle: 'Информация о владельце сада',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenGarden'),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        leading: Icon(Icons.spa_outlined, color: scheme.primary),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.spa_rounded,
                            size: 48,
                            color: scheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Растём вместе',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Любимым растениям — немного заботы каждый день. '
                            'Храните свою коллекцию и планируйте уход в одном месте.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onPrimaryContainer,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Ваш сад',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.builder(
                    itemCount: _sections.length,
                    itemBuilder: (context, index) {
                      final section = _sections[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: scheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            onTap: index <= 1
                                ? () => Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => index == 0
                                          ? const LoginScreen()
                                          : const PlantsScreen(),
                                    ),
                                  )
                                : null,
                            trailing: index <= 1
                                ? const Icon(Icons.chevron_right_rounded)
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                section.icon,
                                color: scheme.onSecondaryContainer,
                              ),
                            ),
                            title: Text(
                              section.title,
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(section.subtitle),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
