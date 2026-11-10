import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/garden_model.dart';
import 'error_view.dart';

class GardenPage extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? floatingActionButton;
  final List<Widget> actions;
  const GardenPage({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
        ...actions,
        IconButton(
          tooltip: 'Обновить',
          onPressed: () => context.read<GardenModel>().load(),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    floatingActionButton: floatingActionButton,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: child,
        ),
      ),
    ),
  );
}

class GardenDataView extends StatelessWidget {
  final Widget Function(GardenModel model) builder;
  const GardenDataView({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GardenModel>();
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.error != null) {
      return ErrorView(
        message: model.error!,
        onRetry: () => context.read<GardenModel>().load(),
      );
    }
    return builder(model);
  }
}

class GardenHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const GardenHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: scheme.onPrimaryContainer),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onPrimaryContainer,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class GardenEmptyView extends StatelessWidget {
  final String message;
  final Widget? action;
  const GardenEmptyView({super.key, required this.message, this.action});
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_outlined, size: 56),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}

Widget missingPlant(BuildContext context) => GardenEmptyView(
  message: 'Растение не существует',
  action: FilledButton(
    onPressed: () => context.go('/plants'),
    child: const Text('К моим растениям'),
  ),
);

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool?> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) => showDialog<bool>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext, false),
        child: const Text('Отмена'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(dialogContext, true),
        child: Text(confirmLabel),
      ),
    ],
  ),
);

InputDecoration fieldDecoration(
  BuildContext context,
  String label,
  String hint,
  IconData icon,
) => InputDecoration(
  labelText: label,
  hintText: hint,
  floatingLabelBehavior: FloatingLabelBehavior.always,
  prefixIcon: Icon(icon),
  filled: true,
  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
  errorMaxLines: 2,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
);
