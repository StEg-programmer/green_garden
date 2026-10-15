import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../widgets/plant_card.dart';

class PlantFormScreen extends StatefulWidget {
  final String? plantId;

  const PlantFormScreen({super.key, this.plantId});

  @override
  State<PlantFormScreen> createState() => _PlantFormScreenState();
}

class _PlantFormScreenState extends State<PlantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _intervalController = TextEditingController();
  Plant? _plant;

  @override
  void initState() {
    super.initState();
    _loadPlant();
  }

  @override
  void didUpdateWidget(covariant PlantFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plantId != widget.plantId) {
      _formKey.currentState?.reset();
      _loadPlant();
    }
  }

  void _loadPlant() {
    _plant = widget.plantId == null
        ? null
        : mockPlants.firstWhere((plant) => plant.id == widget.plantId);
    _nameController.text = _plant?.name ?? '';
    _speciesController.text = _plant?.species ?? '';
    _intervalController.text = (_plant?.wateringIntervalDays ?? 7).toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите название растения';
    }
    return null;
  }

  String? _validateInterval(String? value) {
    if (value == null || value.trim().isEmpty) return 'Укажите интервал полива';
    final days = int.tryParse(value.trim());
    if (days == null) return 'Введите целое число дней';
    if (days < 1) return 'Интервал полива должен быть не меньше 1 дня';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Сохранено: ${_nameController.text.trim()}')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final plant = _plant;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isEditing = plant != null;

    InputDecoration fieldDecoration(String label, String hint, IconData icon) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(icon),
        errorMaxLines: 2,
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
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                            isEditing
                                ? 'Обновите сведения о любимом растении.'
                                : 'Дайте растению имя и укажите привычный интервал полива.',
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
                      Text(
                        'Текущие данные',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      PlantCard(plant: plant),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      'Информация о растении',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      validator: _validateName,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: fieldDecoration(
                        'Название растения',
                        'Например, Монстера у окна',
                        Icons.edit_outlined,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _speciesController,
                      textInputAction: TextInputAction.next,
                      decoration: fieldDecoration(
                        'Вид растения',
                        'Например, Monstera deliciosa',
                        Icons.eco_outlined,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _intervalController,
                      validator: _validateInterval,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                      decoration: fieldDecoration(
                        'Интервал полива, дней',
                        'Например, 7',
                        Icons.water_drop_outlined,
                      ),
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
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: const Text('Выбрать фото'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: _save,
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
      ),
    );
  }
}
