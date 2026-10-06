import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/plant_card.dart';

class PlantDetailsScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailsScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final care = mockPlantCare[plant.id]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка растения'),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            children: [

                              Icon(
                                Icons.eco_rounded,
                                size: 112,
                                color: scheme.onPrimaryContainer,
                                semanticLabel:
                                    'Изображение растения: ${plant.name}',
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Каждый лист — маленькая история',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        PlantCard(plant: plant),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Редактировать растение'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const _SectionHeading(
                  title: 'История поливов',
                  subtitle: 'Последние записи об уходе',
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.builder(
                    itemCount: care.history.length,
                    itemBuilder: (context, index) {
                      final entry = care.history[index];
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            leading: Icon(
                              Icons.water_drop_outlined,
                              color: scheme.primary,
                            ),
                            title: Text(
                              entry.dateLabel,
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(entry.note),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const _SectionHeading(
                  title: 'Напоминания',
                  subtitle: 'Запланированные и выполненные поливы',
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.builder(
                    itemCount: care.reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = care.reminders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: scheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.title,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  reminder.dateLabel,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  children: [
                                    Chip(
                                      avatar: Icon(
                                        reminder.isCompleted
                                            ? Icons.check_circle_outline_rounded
                                            : Icons.schedule_rounded,
                                        size: 18,
                                        color: reminder.isCompleted
                                            ? scheme.onPrimaryContainer
                                            : scheme.onTertiaryContainer,
                                      ),
                                      label: Text(
                                        reminder.isCompleted
                                            ? 'Выполнено'
                                            : 'Запланировано',
                                      ),
                                      labelStyle: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: reminder.isCompleted
                                                ? scheme.onPrimaryContainer
                                                : scheme.onTertiaryContainer,
                                          ),
                                      backgroundColor: reminder.isCompleted
                                          ? scheme.primaryContainer
                                          : scheme.tertiaryContainer,
                                      side: BorderSide.none,
                                    ),
                                  ],
                                ),
                              ],
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


class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
