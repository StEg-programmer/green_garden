import 'package:flutter/material.dart';

import '../data/plant.dart';

class StatusBadge extends StatelessWidget {
  final WateringStatus status;
  const StatusBadge({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final due = status == WateringStatus.due;
    final color = due ? scheme.onTertiaryContainer : scheme.onPrimaryContainer;
    final label = switch (status) {
      WateringStatus.due => 'Пора поливать',
      WateringStatus.watered => 'Полито',
      WateringStatus.notWatered => 'Нет поливов',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: due ? scheme.tertiaryContainer : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            due ? Icons.water_drop_outlined : Icons.eco_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
