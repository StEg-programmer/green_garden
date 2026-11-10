import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_garden/router.dart';

import 'test_support.dart';

void main() {
  testWidgets('Name and interval validation remain from L3', (tester) async {
    await boot(tester, '/plants/new');
    await tester.enterText(find.byKey(const ValueKey('plant-interval')), '0');
    await press(tester, 'Добавить растение');
    expect(find.text('Введите название растения'), findsOneWidget);
    expect(
      find.text('Интервал полива должен быть не меньше 1 дня'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Valid create updates list badge and profile, and new id opens directly',
    (tester) async {
      await boot(tester, '/plants/new');
      await tester.enterText(
        find.byKey(const ValueKey('plant-name')),
        'Базилик',
      );
      await tester.enterText(find.byKey(const ValueKey('plant-interval')), '1');
      await press(tester, 'Добавить растение');
      expect(garden(tester).plants.length, 9);
      final created = garden(tester).plants.last;
      expect(created.id, isNotEmpty);
      router.go('/plants/${created.id}');
      await tester.pumpAndSettle();
      expect(find.text('Базилик'), findsWidgets);
      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('profile-plant-count')))
            .data,
        '9',
      );
    },
  );

  testWidgets('Editing persists and failure retains the draft', (tester) async {
    final failures = await boot(tester, '/plants/ficus/edit');
    final name = find.byKey(const ValueKey('plant-name'));
    expect(
      tester.widget<TextFormField>(name).controller!.text,
      'Фикус в гостиной',
    );
    await tester.enterText(name, 'Фикус у двери');
    failures.simulateError = true;
    await press(tester, 'Сохранить изменения');
    expect(find.text('Сервер не отвечает — повторите попытку'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(name).controller!.text,
      'Фикус у двери',
    );
    expect(garden(tester).byId('ficus')!.name, 'Фикус в гостиной');
    failures.simulateError = false;
    await press(tester, 'Сохранить изменения');
    expect(garden(tester).byId('ficus')!.name, 'Фикус у двери');
    expect(find.widgetWithText(AppBar, 'Карточка растения'), findsOneWidget);
  });

  testWidgets('Confirmed deletion removes plant logs and reminders', (
    tester,
  ) async {
    await boot(tester, '/plants/monstera');
    await press(tester, 'Удалить растение');
    await tester.tap(find.widgetWithText(FilledButton, 'Удалить'));
    await tester.pumpAndSettle();
    expect(garden(tester).byId('monstera'), isNull);
    expect(garden(tester).waterings.length, 42);
    expect(
      garden(tester).reminders.where((item) => item.plantId == 'monstera'),
      isEmpty,
    );
    expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
  });
}
