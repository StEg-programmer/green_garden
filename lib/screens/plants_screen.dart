import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/garden_model.dart';
import '../widgets/garden_widgets.dart';
import '../widgets/plant_card.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});
  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<bool> _remove(String id) async {
    final confirmed = await confirmAction(
      context,
      title: 'Удалить растение?',
      message: 'Растение и его история поливов будут удалены.',
      confirmLabel: 'Удалить',
    );
    if (confirmed != true || !mounted) return false;
    final error = await context.read<GardenModel>().removePlant(id);
    if (mounted) showMessage(context, error ?? 'Растение удалено');
    return false;
  }

  @override
  Widget build(BuildContext context) => GardenPage(
    title: 'Мои растения',
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.push('/plants/new'),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Добавить растение'),
    ),
    child: GardenDataView(
      builder: (model) {
        final query = _search.text.trim().toLowerCase();
        final plants = model.plants
            .where(
              (plant) => '${plant.name} ${plant.species}'
                  .toLowerCase()
                  .contains(query),
            )
            .toList();
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              sliver: SliverToBoxAdapter(
                child: GardenHeader(
                  icon: Icons.local_florist_outlined,
                  title: 'Ваш зелёный уголок',
                  subtitle:
                      '${model.plants.length} растений в коллекции\nПора поливать: ${model.dueCount}',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: fieldDecoration(
                    context,
                    'Поиск',
                    'Название или вид растения',
                    Icons.search_rounded,
                  ),
                ),
              ),
            ),
            if (plants.isEmpty)
              SliverToBoxAdapter(
                child: GardenEmptyView(
                  message: model.plants.isEmpty
                      ? 'В вашем саду пока нет растений. Добавьте первое.'
                      : 'Растения не найдены',
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 104),
              sliver: SliverList.builder(
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  return Padding(
                    key: ValueKey(plant.id),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(plant.id),
                      direction: model.isSaving
                          ? DismissDirection.none
                          : DismissDirection.endToStart,
                      confirmDismiss: (_) => _remove(plant.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.all(24),
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: const Icon(Icons.delete_outline),
                      ),
                      child: PlantCard(
                        plant: plant,
                        onTap: () => context.push('/plants/${plant.id}'),
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
