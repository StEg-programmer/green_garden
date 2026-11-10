import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/date_helpers.dart';
import '../data/watering_entry.dart';
import '../models/garden_model.dart';
import '../widgets/garden_widgets.dart';
import '../widgets/watering_card.dart';

class WateringLogScreen extends StatelessWidget {
  final String? plantId;
  final String? entryId;
  const WateringLogScreen({super.key, this.plantId, this.entryId});

  Future<void> _remove(BuildContext context, String id) async {
    final confirmed = await confirmAction(
      context,
      title: 'Отменить полив?',
      message: 'Запись исчезнет из журнала. Срок следующего полива будет пересчитан.',
      confirmLabel: 'Отменить полив',
    );
    if (confirmed != true || !context.mounted) return;
    final error = await context.read<GardenModel>().removeWatering(id);
    if (context.mounted) showMessage(context, error ?? 'Полив отменён');
  }

  @override
  Widget build(BuildContext context) => GardenPage(
    title: entryId == null ? 'Журнал полива' : 'Редактировать полив',
    child: GardenDataView(
      builder: (model) {
        if (plantId != null && model.byId(plantId!) == null) {
          return missingPlant(context);
        }
        final entry = entryId == null ? null : model.wateringById(entryId!);
        if (entryId != null && entry == null) {
          return const GardenEmptyView(message: 'Запись полива не существует');
        }
        if (model.plants.isEmpty) {
          return const GardenEmptyView(
            message: 'Сначала добавьте растение в свой сад.',
          );
        }
        final history = plantId == null
            ? model.waterings
            : model.historyFor(plantId!);
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GardenHeader(
                      icon: Icons.water_drop_outlined,
                      title: 'Капля заботы',
                      subtitle: 'Отмечайте поливы и сохраняйте наблюдения.',
                    ),
                    const SizedBox(height: 24),
                    _WateringEditor(
                      key: ValueKey(entryId ?? plantId ?? 'new'),
                      plantId: plantId,
                      entry: entry,
                    ),
                    if (entryId == null) ...[
                      const SizedBox(height: 28),
                      Text(
                        'История поливов',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                    if (entryId == null && history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Поливов пока нет'),
                      ),
                  ],
                ),
              ),
            ),
            if (entryId == null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    final plant = model.byId(entry.plantId);
                    if (plant == null) return const SizedBox.shrink();
                    return Padding(
                      key: ValueKey(entry.id),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: WateringCard(
                        entry: entry,
                        plant: plant,
                        onEdit: model.isSaving
                            ? null
                            : () => context.push(
                                '/watering-log/${entry.id}/edit',
                              ),
                        onDelete: model.isSaving
                            ? null
                            : () => _remove(context, entry.id),
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

class _WateringEditor extends StatefulWidget {
  final String? plantId;
  final WateringEntry? entry;
  const _WateringEditor({super.key, this.plantId, this.entry});
  @override
  State<_WateringEditor> createState() => _WateringEditorState();
}

class _WateringEditorState extends State<_WateringEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _date;
  late final TextEditingController _note;
  DateTime? _selectedDate;
  String? _selectedPlant;
  @override
  void initState() {
    super.initState();
    _selectedPlant = widget.entry?.plantId ?? widget.plantId;
    _selectedDate = widget.entry?.wateredAt;
    _date = TextEditingController(
      text: _selectedDate == null ? '' : formatDate(_selectedDate!),
    );
    _note = TextEditingController(text: widget.entry?.note ?? '');
  }

  @override
  void dispose() {
    _date.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final today = dateOnly(DateTime.now());
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
      _date.text = formatDate(date);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final model = context.read<GardenModel>();
    final draft = WateringEntry(
      id: widget.entry?.id ?? '',
      plantId: _selectedPlant!,
      wateredAt: _selectedDate!,
      note: _note.text.trim(),
    );
    final error = widget.entry == null
        ? await model.addWatering(draft)
        : await model.updateWatering(draft);
    if (!mounted) return;
    showMessage(context, error ?? 'Полив сохранён');
    if (error == null) {
      FocusScope.of(context).unfocus();
      if (widget.entry != null || widget.plantId != null) {
        context.pop();
      } else {
        _note.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GardenModel>();
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.entry == null ? 'Отметить полив' : 'Редактировать запись',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            key: const ValueKey('watering-plant'),
            initialValue: model.byId(_selectedPlant ?? '')?.id,
            isExpanded: true,
            decoration: fieldDecoration(
              context,
              'Растение',
              'Выберите растение',
              Icons.eco_outlined,
            ),
            validator: (value) => value == null || model.byId(value) == null
                ? 'Выберите растение'
                : null,
            onChanged: model.isSaving
                ? null
                : (value) => setState(() => _selectedPlant = value),
            items: model.plants
                .map(
                  (plant) => DropdownMenuItem(
                    value: plant.id,
                    child: Text(plant.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          TextFormField(
            key: const ValueKey('watering-date'),
            controller: _date,
            readOnly: true,
            onTap: _pickDate,
            decoration: fieldDecoration(
              context,
              'Дата полива',
              'Выберите дату в календаре',
              Icons.calendar_today_outlined,
            ),
            validator: (_) => _selectedDate == null
                ? 'Выберите дату полива'
                : dateOnly(_selectedDate!).isAfter(dateOnly(DateTime.now()))
                ? 'Дата полива не может быть в будущем'
                : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            key: const ValueKey('watering-note'),
            controller: _note,
            minLines: 3,
            maxLines: 6,
            decoration: fieldDecoration(
              context,
              'Заметка',
              'Ваши наблюдения о растении',
              Icons.notes_rounded,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: model.isSaving ? null : _save,
            icon: model.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(
              widget.entry == null ? 'Отметить полив' : 'Сохранить изменения',
            ),
          ),
        ],
      ),
    );
  }
}
