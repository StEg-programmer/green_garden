import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/date_helpers.dart';
import '../models/garden_model.dart';
import '../widgets/garden_widgets.dart';
import '../widgets/plant_card.dart';
import '../widgets/watering_card.dart';

class PlantDetailsScreen extends StatelessWidget {
  final String id;
  const PlantDetailsScreen({super.key, required this.id});

  Future<void> _remove(BuildContext context) async {
    final confirmed = await confirmAction(
      context,
      title: 'Удалить растение?',
      message:
          'Будут удалены растение, история поливов и связанные напоминания.',
      confirmLabel: 'Удалить',
    );
    if (confirmed != true || !context.mounted) return;
    final error = await context.read<GardenModel>().removePlant(id);
    if (!context.mounted) return;
    showMessage(context, error ?? 'Растение удалено');
    if (error == null) context.go('/plants');
  }

  @override
  Widget build(BuildContext context) => GardenPage(
    title: 'Карточка растения',
    child: GardenDataView(
      builder: (model) {
        final plant = model.byId(id);
        if (plant == null) return missingPlant(context);
        final history = model.historyFor(id);
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GardenHeader(
                      icon: Icons.eco_rounded,
                      title: plant.name,
                      subtitle: plant.species.isEmpty
                          ? 'Каждый лист — маленькая история'
                          : plant.species,
                    ),
                    const SizedBox(height: 16),
                    PlantCard(plant: plant),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.push('/plants/$id/watering'),
                      icon: const Icon(Icons.water_drop_outlined),
                      label: const Text('Отметить полив'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/plants/$id/edit'),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Редактировать растение'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/plants/$id/reminders'),
                      icon: const Icon(Icons.notifications_none_rounded),
                      label: const Text('Напоминания этого растения'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Следующий полив: ${formatDateTime(model.nextWateringAt(plant))}',
                    ),
                    TextButton.icon(
                      onPressed: model.isSaving ? null : () => _remove(context),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Удалить растение'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'История поливов',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Поливы пока не отмечены'),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.builder(
                itemCount: history.length,
                itemBuilder: (context, index) => Padding(
                  key: ValueKey(history[index].id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WateringCard(entry: history[index], plant: plant),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
