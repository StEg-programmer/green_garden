import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_garden/router.dart';

import 'test_support.dart';

void main() {
  testWidgets(
    'Journal requires plant and date and calendar excludes future days',
    (tester) async {
      await boot(tester, '/watering-log');
      await press(tester, 'Отметить полив');
      expect(find.text('Выберите дату полива'), findsOneWidget);
      expect(
        tester
            .state<FormFieldState<String>>(
              find.byKey(const ValueKey('watering-plant')),
            )
            .errorText,
        'Выберите растение',
      );
      await selectToday(tester);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('watering-date')))
            .controller!
            .text,
        isNotEmpty,
      );
    },
  );

  testWidgets('Watering a plant updates history schedule and profile count', (
    tester,
  ) async {
    await boot(tester, '/plants/ficus/watering');
    final oldDue = garden(tester).nextWateringAt(garden(tester).byId('ficus')!);
    await selectToday(tester);
    await tester.enterText(
      find.byKey(const ValueKey('watering-note')),
      'Полил утром',
    );
    await press(tester, 'Отметить полив');
    expect(garden(tester).waterings.length, 51);
    expect(garden(tester).historyFor('ficus').first.note, 'Полил утром');
    expect(
      garden(tester)
          .nextWateringAt(garden(tester).byId('ficus')!)
          .isAfter(oldDue),
      isTrue,
    );
    expect(find.widgetWithText(AppBar, 'Карточка растения'), findsOneWidget);
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('profile-watering-count')))
          .data,
      '51',
    );
  });

  testWidgets('Edit watering loads its data and really changes the record', (
    tester,
  ) async {
    await boot(tester, '/watering-log');
    final entry = garden(tester).waterings.first;
    router.go('/watering-log/${entry.id}/edit');
    await tester.pumpAndSettle();
    final note = find.byKey(const ValueKey('watering-note'));
    expect(tester.widget<TextFormField>(note).controller!.text, entry.note);
    await tester.enterText(note, 'Исправленная заметка');
    await press(tester, 'Сохранить изменения');
    expect(garden(tester).wateringById(entry.id)!.note, 'Исправленная заметка');
    expect(find.widgetWithText(AppBar, 'Журнал полива'), findsOneWidget);
  });
  testWidgets(
    'Deleting a selected plant from another tab clears the journal selection',
    (tester) async {
      await boot(tester, '/watering-log');
      final dropdown = find.byKey(const ValueKey('watering-plant'));
      await reveal(tester, dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Фикус в гостиной').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('watering-note')),
        'Черновик сохраняется',
      );
      await tester.tap(find.text('Растения'));
      await tester.pumpAndSettle();
      final removal = garden(tester).removePlant('ficus');
      await tester.pumpAndSettle();
      await removal;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Журнал'));
      await tester.pumpAndSettle();
      expect(tester.state<FormFieldState<String>>(dropdown).value, isNull);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('watering-note')))
            .controller!
            .text,
        'Черновик сохраняется',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
