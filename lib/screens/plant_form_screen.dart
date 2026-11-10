import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/plant.dart';
import '../models/garden_model.dart';
import '../widgets/garden_widgets.dart';

class PlantFormScreen extends StatelessWidget {
  final String? plantId;
  const PlantFormScreen({super.key, this.plantId});
  @override
  Widget build(BuildContext context) => GardenPage(
    title: plantId == null ? 'Новое растение' : 'Редактировать растение',
    child: GardenDataView(
      builder: (model) {
        final plant = plantId == null ? null : model.byId(plantId!);
        if (plantId != null && plant == null) return missingPlant(context);
        return _PlantEditor(key: ValueKey(plantId ?? 'new'), plant: plant);
      },
    ),
  );
}

class _PlantEditor extends StatefulWidget {
  final Plant? plant;
  const _PlantEditor({super.key, this.plant});
  @override
  State<_PlantEditor> createState() => _PlantEditorState();
}

class _PlantEditorState extends State<_PlantEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _species;
  late final TextEditingController _interval;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.plant?.name ?? '');
    _species = TextEditingController(text: widget.plant?.species ?? '');
    _interval = TextEditingController(
      text: '${widget.plant?.wateringIntervalDays ?? 7}',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _interval.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final model = context.read<GardenModel>();
    final draft = Plant(
      id: widget.plant?.id ?? '',
      name: _name.text.trim(),
      species: _species.text.trim(),
      wateringIntervalDays: int.parse(_interval.text),
      createdAt: widget.plant?.createdAt ?? DateTime.now(),
    );
    final error = widget.plant == null
        ? await model.addPlant(draft)
        : await model.updatePlant(draft);
    if (!mounted) return;
    showMessage(context, error ?? 'Сохранено: ${draft.name}');
    if (error == null) {
      FocusScope.of(context).unfocus();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<GardenModel>().isSaving;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GardenHeader(
              icon: Icons.local_florist_outlined,
              title: widget.plant == null
                  ? 'Новый житель вашего сада'
                  : 'Забота в деталях',
              subtitle: 'Название, вид и привычный интервал полива.',
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const ValueKey('plant-name'),
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: fieldDecoration(
                context,
                'Название растения',
                'Например, Монстера у окна',
                Icons.edit_outlined,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Введите название растения'
                  : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const ValueKey('plant-species'),
              controller: _species,
              textInputAction: TextInputAction.next,
              decoration: fieldDecoration(
                context,
                'Вид растения',
                'Например, Monstera deliciosa',
                Icons.eco_outlined,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const ValueKey('plant-interval'),
              controller: _interval,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!busy) _save();
              },
              decoration: fieldDecoration(
                context,
                'Интервал полива, дней',
                'Например, 7',
                Icons.water_drop_outlined,
              ),
              validator: (value) {
                final days = int.tryParse(value ?? '');
                if (days == null) return 'Введите целое число дней';
                if (days < 1) {
                  return 'Интервал полива должен быть не меньше 1 дня';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                children: [
                  Icon(Icons.image_outlined, size: 56),
                  SizedBox(height: 12),
                  Text('Фото растения', textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: busy ? null : _save,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(
                widget.plant == null
                    ? 'Добавить растение'
                    : 'Сохранить изменения',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
