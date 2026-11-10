import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/date_helpers.dart';
import '../data/mock_failure_controller.dart';
import '../data/user_profile.dart';
import '../models/garden_model.dart';
import '../widgets/garden_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _simulateError;
  @override
  void initState() {
    super.initState();
    _simulateError = context.read<MockFailureController>().simulateError;
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы вернётесь на экран входа.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Остаться'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) => GardenPage(
    title: 'Мой профиль',
    child: Column(
      children: [
        SwitchListTile(
          title: const Text('Симулировать сбой сети'),
          subtitle: const Text('Проверка обработки ошибок'),
          value: _simulateError,
          onChanged: (value) {
            context.read<MockFailureController>().simulateError = value;
            setState(() => _simulateError = value);
          },
        ),
        Expanded(
          child: GardenDataView(
            builder: (model) {
              final profile = model.profile!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            child: Text(
                              profile.initials,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile.name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(profile.email, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Мой зелёный уголок',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.eco_outlined),
                            title: const Text('Растений в коллекции'),
                            trailing: Text(
                              '${model.plants.length}',
                              key: const ValueKey('profile-plant-count'),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.water_drop_outlined),
                            title: const Text('Записей о поливе'),
                            trailing: Text(
                              '${model.waterings.length}',
                              key: const ValueKey('profile-watering-count'),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.notifications_none_rounded,
                            ),
                            title: const Text('Пора поливать'),
                            trailing: Text('${model.dueCount}'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Данные аккаунта',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Имя'),
                            subtitle: Text(profile.name),
                          ),
                          ListTile(
                            title: const Text('Электронная почта'),
                            subtitle: Text(profile.email),
                          ),
                          ListTile(
                            title: const Text('С нами с'),
                            subtitle: Text(formatDate(profile.joinedAt)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: model.isSaving
                          ? null
                          : () => showDialog<void>(
                              context: context,
                              builder: (_) => _ProfileEditor(profile: profile),
                            ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Редактировать профиль'),
                    ),
                    TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Выйти из аккаунта'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _ProfileEditor extends StatefulWidget {
  final UserProfile profile;
  const _ProfileEditor({required this.profile});
  @override
  State<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<_ProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _email = TextEditingController(text: widget.profile.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<GardenModel>().updateProfile(
      UserProfile(
        name: _name.text.trim(),
        email: _email.text.trim(),
        joinedAt: widget.profile.joinedAt,
      ),
    );
    if (!mounted) return;
    showMessage(context, error ?? 'Профиль обновлён');
    if (error == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<GardenModel>().isSaving;
    return AlertDialog(
      title: const Text('Редактировать профиль'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Введите имя'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Электронная почта',
                ),
                validator: (value) =>
                    value == null ||
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())
                    ? 'Введите корректный e-mail'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: busy ? null : _save,
          child: Text(busy ? 'Сохранение…' : 'Сохранить'),
        ),
      ],
    );
  }
}
