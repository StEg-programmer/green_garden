import 'package:flutter/material.dart';

import '../data/date_helpers.dart';
import '../data/plant.dart';
import '../data/watering_entry.dart';

class WateringCard extends StatelessWidget {
  final WateringEntry entry;
  final Plant plant;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const WateringCard({
    super.key,
    required this.entry,
    required this.plant,
    this.onEdit,
    this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plant.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatDate(entry.wateredAt),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(entry.note.isEmpty ? 'Без заметки' : entry.note),
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Редактировать'),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.undo_rounded, size: 18),
                    label: const Text('Отменить полив'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
