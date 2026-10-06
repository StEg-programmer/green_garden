import 'package:flutter/material.dart';

import '../data/mock_data.dart';

class StatusBadge extends StatelessWidget {
  final WateringStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDue = status == WateringStatus.due;
    final foreground = isDue
        ? scheme.onTertiaryContainer
        : scheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDue ? scheme.tertiaryContainer : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDue
                ? Icons.water_drop_outlined
                : Icons.check_circle_outline_rounded,
            size: 16,
            color: foreground,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              isDue ? 'Пора поливать' : 'Полито',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
