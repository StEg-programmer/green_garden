import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/plant_card.dart';

class WateringLogScreen extends StatelessWidget {
  final Plant? plant;

  const WateringLogScreen({super.key, this.plant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selectedPlant = plant ?? mockPlants.first;
    final List<({Plant plant, WateringEntry entry})> records;

    if (plant != null) {
      records = mockPlantCare[plant!.id]!.history
          .map((entry) => (plant: plant!, entry: entry))
          .toList();
    } else {
      records = mockPlants
          .map(
            (item) =>
                (plant: item, entry: mockPlantCare[item.id]!.history.first),
          )
          .toList();
    }

    InputDecoration decoration(String label, String hint, IconData icon) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал полива'),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.water_drop_outlined,
                                size: 48,
                                color: scheme.onPrimaryContainer,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Капля заботы',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Отмечайте поливы и сохраняйте наблюдения о своих растениях.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Отметить полив',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (plant != null)
                          PlantCard(plant: plant!)
                        else
                          DropdownMenu<String>(
                            initialSelection: selectedPlant.id,
                            expandedInsets: EdgeInsets.zero,
                            requestFocusOnTap: false,
                            enableSearch: false,
                            enableFilter: false,
                            label: const Text('Растение'),
                            leadingIcon: const Icon(Icons.eco_outlined),
                            inputDecorationTheme: InputDecorationTheme(
                              filled: true,
                              fillColor: scheme.surfaceContainerLow,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            dropdownMenuEntries: mockPlants
                                .map(
                                  (item) => DropdownMenuEntry(
                                    value: item.id,
                                    label: item.name,
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 20),
                        TextField(
                          textInputAction: TextInputAction.next,
                          decoration: decoration(
                            'Дата полива',
                            'Например, 7 октября',
                            Icons.calendar_today_outlined,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          minLines: 3,
                          maxLines: 6,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: decoration(
                            'Заметка',
                            'Как выглядит растение? Была ли почва сухой?',
                            Icons.notes_rounded,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Отметить полив'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant != null
                              ? 'История поливов'
                              : 'Последние поливы',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          plant != null
                              ? selectedPlant.name
                              : 'Последняя запись для каждого растения',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                                  record.plant.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.water_drop_outlined,
                                      size: 18,
                                      color: scheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        record.entry.dateLabel,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  record.entry.note,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.4,
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
