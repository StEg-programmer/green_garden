import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/plant_card.dart';
import 'plant_details_screen.dart';
import 'plant_form_screen.dart';

class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dueCount = mockPlants
        .where((plant) => plant.wateringStatus == WateringStatus.due)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои растения'),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => const PlantFormScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Добавить растение'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                            Icons.local_florist_outlined,
                            size: 40,
                            color: scheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ваш зелёный уголок',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${mockPlants.length} растений в коллекции',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Пора поливать: $dueCount',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverToBoxAdapter(
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Поиск по названию или виду',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: scheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Все растения',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 104),
                  sliver: SliverList.builder(
                    itemCount: mockPlants.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PlantCard(
                        plant: mockPlants[index],
                        onTap: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PlantDetailsScreen(plant: mockPlants[index]),
                          ),
                        ),
                      ),
                    ),
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
