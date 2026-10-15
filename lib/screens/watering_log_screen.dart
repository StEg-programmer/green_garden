import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../widgets/plant_card.dart';

class WateringLogScreen extends StatefulWidget {
  final String? plantId;

  const WateringLogScreen({super.key, this.plantId});

  @override
  State<WateringLogScreen> createState() => _WateringLogScreenState();
}

class _WateringLogScreenState extends State<WateringLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _noteController = TextEditingController();
  Plant? _plant;
  String? _selectedPlantId;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadPlant();
  }

  @override
  void didUpdateWidget(covariant WateringLogScreen oldWidget) {
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
    _selectedPlantId = _plant?.id;
    _selectedDate = null;
    _dateController.clear();
    _noteController.clear();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? _validatePlant(String? value) {
    if (value == null || value.isEmpty) return 'Выберите растение';
    return null;
  }

  String? _validateDate(String? value) {
    if (_selectedDate == null) return 'Выберите дату полива';
    if (_selectedDate!.isAfter(DateUtils.dateOnly(DateTime.now()))) {
      return 'Дата полива не может быть в будущем';
    }
    return null;
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: DateTime(1900),
      lastDate: today,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Дата полива',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
    );
    if (!mounted || date == null) return;
    setState(() {
      _selectedDate = date;
      _dateController.text =
          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final selectedPlant = mockPlants.firstWhere(
      (plant) => plant.id == _selectedPlantId,
    );
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Полив отмечен: ${selectedPlant.name} · ${_dateController.text}',
        ),
      ),
    );
    if (widget.plantId != null) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final plant = _plant;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selectedPlant = plant ?? mockPlants.first;
    final List<({Plant plant, WateringEntry entry})> records;

    if (plant != null) {
      records = mockPlantCare[plant.id]!.history
          .map((entry) => (plant: plant, entry: entry))
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
        errorMaxLines: 2,
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
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
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
                            PlantCard(plant: plant)
                          else
                            DropdownButtonFormField<String>(
                              initialValue: _selectedPlantId,
                              isExpanded: true,
                              decoration: decoration(
                                'Растение',
                                'Выберите растение',
                                Icons.eco_outlined,
                              ),
                              validator: _validatePlant,
                              onChanged: (value) =>
                                  setState(() => _selectedPlantId = value),
                              items: mockPlants
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item.id,
                                      child: Text(
                                        item.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            validator: _validateDate,
                            onTap: _pickDate,
                            decoration:
                                decoration(
                                  'Дата полива',
                                  'Выберите дату в календаре',
                                  Icons.calendar_today_outlined,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    tooltip: 'Выбрать дату',
                                    onPressed: _pickDate,
                                    icon: const Icon(Icons.date_range_outlined),
                                  ),
                                ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _noteController,
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
                            onPressed: _save,
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
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
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
      ),
    );
  }
}
