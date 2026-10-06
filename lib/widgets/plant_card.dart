import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import 'status_badge.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;

  const PlantCard({super.key, required this.plant, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(24);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.eco_outlined,
                      size: 32,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plant.species,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null) const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusBadge(status: plant.wateringStatus),
                  Text(
                    'Интервал: ${plant.wateringIntervalDays} дн.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Последний полив: ${plant.lastWateredLabel}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
