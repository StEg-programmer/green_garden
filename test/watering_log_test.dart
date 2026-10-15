import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:green_garden/data/mock_data.dart';
import 'package:green_garden/main.dart';
import 'package:green_garden/router.dart';

Future<void> openJournal(WidgetTester tester, String location) async {
  router.go(location);
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

Future<void> submitWatering(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Отметить полив');
  await Scrollable.ensureVisible(tester.element(button), alignment: 0.3);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> selectToday(WidgetTester tester) async {
  final dateField = find.byType(TextFormField).first;
  await Scrollable.ensureVisible(tester.element(dateField), alignment: 0.3);
  await tester.pumpAndSettle();
  await tester.tap(dateField);
  await tester.pumpAndSettle();
  expect(find.byType(DatePickerDialog), findsOneWidget);
  final picker = tester.widget<CalendarDatePicker>(
    find.byType(CalendarDatePicker),
  );
  expect(picker.lastDate, DateUtils.dateOnly(DateTime.now()));
  await tester.tap(find.text('Выбрать'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('General journal requires a plant and date', (tester) async {
    await openJournal(tester, '/watering-log');
    await submitWatering(tester);
    expect(find.text('Выберите дату полива'), findsOneWidget);
    expect(
      tester
          .state<FormFieldState<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .errorText,
      'Выберите растение',
    );
    expect(find.widgetWithText(AppBar, 'Журнал полива'), findsOneWidget);
  });

  testWidgets('Selected plant and date confirm without changing mock history', (
    tester,
  ) async {
    final count = mockPlantCare.values.fold<int>(
      0,
      (total, care) => total + care.history.length,
    );
    await openJournal(tester, '/watering-log');
    final dropdown = find.byType(DropdownButtonFormField<String>);
    await Scrollable.ensureVisible(tester.element(dropdown), alignment: 0.3);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Фикус в гостиной').last);
    await tester.pumpAndSettle();
    await selectToday(tester);
    await submitWatering(tester);
    expect(find.widgetWithText(AppBar, 'Журнал полива'), findsOneWidget);
    expect(
      find.textContaining('Полив отмечен: Фикус в гостиной'),
      findsOneWidget,
    );
    expect(
      mockPlantCare.values.fold<int>(
        0,
        (total, care) => total + care.history.length,
      ),
      count,
    );
    expect(router.canPop(), isFalse);
  });

  testWidgets('Contextual journal keeps the plant and returns to details', (
    tester,
  ) async {
    await openJournal(tester, '/plants/aloe/watering');
    expect(find.text('Aloe vera'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    await selectToday(tester);
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Почва сухая, полил утром.',
    );
    await submitWatering(tester);
    expect(find.widgetWithText(AppBar, 'Карточка растения'), findsOneWidget);
    expect(find.textContaining('Полив отмечен: Алоэ на кухне'), findsOneWidget);
    expect(mockPlantCare['aloe']!.history.length, 6);
  });

  testWidgets('Cancelling the calendar does not fill in a date', (
    tester,
  ) async {
    await openJournal(tester, '/plants/monstera/watering');
    final dateField = find.byType(TextFormField).first;
    await Scrollable.ensureVisible(tester.element(dateField), alignment: 0.3);
    await tester.pumpAndSettle();
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextFormField>(dateField).controller!.text, isEmpty);
    await submitWatering(tester);
    expect(find.text('Выберите дату полива'), findsOneWidget);
  });

  testWidgets('A new contextual id clears the previous draft', (tester) async {
    await openJournal(tester, '/plants/ficus/watering');
    await selectToday(tester);
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Заметка о фикусе',
    );
    router.go('/plants/zz/watering');
    await tester.pumpAndSettle();
    expect(find.text('Zamioculcas zamiifolia'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      isEmpty,
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      isEmpty,
    );
  });
}
