import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/date_helpers.dart';
import '../models/garden_model.dart';
import '../widgets/garden_widgets.dart';

class RemindersScreen extends StatelessWidget {
  final String? plantId;
  const RemindersScreen({super.key, this.plantId});

  Future<void> _cancel(BuildContext context, String id) async {
    final confirmed = await confirmAction(
      context,
      title: 'Отменить выполненный полив?',
      message: 'Запись будет удалена из журнала, а напоминание пересчитано.',
      confirmLabel: 'Отменить полив',
    );
    if (confirmed != true || !context.mounted) return;
    final error = await context.read<GardenModel>().removeWatering(id);
    if (context.mounted) showMessage(context, error ?? 'Полив отменён');
  }

  @override
  Widget build(BuildContext context) => GardenPage(
    title: 'Напоминания',
    child: GardenDataView(
      builder: (model) {
        if (plantId != null && model.byId(plantId!) == null) {
          return missingPlant(context);
        }
        final reminders = model.reminders
            .where((item) => plantId == null || item.plantId == plantId)
            .toList();
        final pending = reminders.where((item) => !item.isCompleted).length;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: GardenHeader(
                  icon: Icons.notifications_none_rounded,
                  title: 'Забота по расписанию',
                  subtitle:
                      '${plantId == null ? 'Ваш сад' : model.byId(plantId!)!.name}\nВ плане: $pending · Выполнено: ${reminders.length - pending}',
                ),
              ),
            ),
            if (reminders.isEmpty)
              const SliverToBoxAdapter(
                child: GardenEmptyView(message: 'Напоминаний пока нет'),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  final plant = model.byId(reminder.plantId)!;
                  final overdue =
                      !reminder.isCompleted &&
                      reminder.dueAt.isBefore(DateTime.now());
                  return Padding(
                    key: ValueKey(reminder.id),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Полить растение · ${formatDateTime(reminder.dueAt)}',
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(
                                reminder.isCompleted
                                    ? 'Выполнено'
                                    : overdue
                                    ? 'Пора поливать'
                                    : 'Запланировано',
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: model.isSaving
                                  ? null
                                  : () {
                                      if (reminder.isCompleted) {
                                        _cancel(context, reminder.id);
                                      } else {
                                        context.push(
                                          '/plants/${plant.id}/watering',
                                        );
                                      }
                                    },
                              icon: Icon(
                                reminder.isCompleted
                                    ? Icons.undo_rounded
                                    : Icons.water_drop_outlined,
                              ),
                              label: Text(
                                reminder.isCompleted
                                    ? 'Отменить полив'
                                    : 'Отметить полив',
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
        );
      },
    ),
  );
}
