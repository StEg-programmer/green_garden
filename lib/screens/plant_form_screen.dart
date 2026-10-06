import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/plant_card.dart';

class PlantFormScreen extends StatelessWidget {
  final Plant? plant;

  const PlantFormScreen({super.key, this.plant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isEditing = plant != null;

    InputDecoration fieldDecoration(String label, String hint, IconData icon) {
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
        title: Text(isEditing ? 'Редактировать растение' : 'Новое растение'),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                      children: [
                        Icon(
                          Icons.local_florist_outlined,
                          size: 72,
                          color: scheme.onPrimaryContainer,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isEditing
                              ? 'Забота в деталях'
                              : 'Новый житель вашего сада',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEditing ? 'Обновите сведения о любимом растении.' : 'Дайте растению имя и укажите привычный интервал полива.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onPrimaryContainer,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (plant != null) ...[
                    Text('Текущие данные', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    PlantCard(plant: plant!),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Информация о растении',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: fieldDecoration(
                      'Название растения',
                      plant?.name ?? 'Например, Монстера у окна',
                      Icons.edit_outlined,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    textInputAction: TextInputAction.next,
                    decoration: fieldDecoration(
                      'Вид растения',
                      plant?.species ?? 'Например, Monstera deliciosa',
                      Icons.eco_outlined,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownMenu<int>(
                    initialSelection: plant?.wateringIntervalDays ?? 7,
                    expandedInsets: EdgeInsets.zero,
                    requestFocusOnTap: false,
                    enableSearch: false,
                    enableFilter: false,
                    label: const Text('Интервал полива'),
                    leadingIcon: const Icon(Icons.water_drop_outlined),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: scheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 3, label: 'Раз в 3 дня'),
                      DropdownMenuEntry(value: 5, label: 'Раз в 5 дней'),
                      DropdownMenuEntry(value: 7, label: 'Раз в 7 дней'),
                      DropdownMenuEntry(value: 10, label: 'Раз в 10 дней'),
                      DropdownMenuEntry(value: 14, label: 'Раз в 14 дней'),
                      DropdownMenuEntry(value: 21, label: 'Раз в 21 день'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Фото растения',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 56,
                          color: scheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Портрет вашего растения',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Выбрать фото'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      isEditing ? Icons.check_rounded : Icons.add_rounded,
                    ),
                    label: Text(
                      isEditing ? 'Сохранить изменения' : 'Добавить растение',
                    ),
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
        ),
      ),
    );
  }
}
