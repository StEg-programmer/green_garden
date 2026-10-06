import 'package:flutter/material.dart';

import '../data/mock_data.dart';

class RemindersScreen extends StatelessWidget {
  final Plant? plant;

  const RemindersScreen({super.key, this.plant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final List<({Plant plant, PlantReminder reminder})> records;

    if (plant != null) {
      records = mockPlantCare[plant!.id]!.reminders
          .map((reminder) => (plant: plant!, reminder: reminder))
          .toList();
    } else {
      records = [
        for (final item in mockPlants)
          (
            plant: item,
            reminder: mockPlantCare[item.id]!.reminders.firstWhere(
              (reminder) => !reminder.isCompleted,
            ),
          ),
        for (final item in mockPlants)
          (
            plant: item,
            reminder: mockPlantCare[item.id]!.reminders.firstWhere(
              (reminder) => reminder.isCompleted,
            ),
          ),
      ];
    }

    final completedCount = records
        .where((record) => record.reminder.isCompleted)
        .length;
    final pendingCount = records.length - completedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Напоминания'),
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
                            Icons.notifications_none_rounded,
                            size: 48,
                            color: scheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Забота по расписанию',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            plant?.name ?? 'Пусть каждый полив будет вовремя.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onPrimaryContainer,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              Chip(
                                label: Text('Не выполнено: $pendingCount'),
                                backgroundColor: scheme.surface,
                                side: BorderSide.none,
                              ),
                              Chip(
                                label: Text('Выполнено: $completedCount'),
                                backgroundColor: scheme.surface,
                                side: BorderSide.none,
                              ),
                            ],
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
                      'План поливов',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final isCompleted = record.reminder.isCompleted;
                      final statusForeground = isCompleted
                          ? scheme.onPrimaryContainer
                          : scheme.onTertiaryContainer;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: scheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      isCompleted
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.notifications_active_outlined,
                                      color: scheme.primary,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.plant.name,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            record.reminder.title,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        record.reminder.dateLabel,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  children: [
                                    Chip(
                                      avatar: Icon(
                                        isCompleted
                                            ? Icons.check_rounded
                                            : Icons.schedule_rounded,
                                        size: 18,
                                        color: statusForeground,
                                      ),
                                      label: Text(
                                        isCompleted
                                            ? 'Выполнено'
                                            : 'Не выполнено',
                                      ),
                                      labelStyle: theme.textTheme.labelLarge
                                          ?.copyWith(color: statusForeground),
                                      backgroundColor: isCompleted
                                          ? scheme.primaryContainer
                                          : scheme.tertiaryContainer,
                                      side: BorderSide.none,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(
                                    isCompleted
                                        ? Icons.undo_rounded
                                        : Icons.check_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    isCompleted
                                        ? 'Вернуть в план'
                                        : 'Отметить выполненным',
                                  ),
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
