import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:green_garden/data/mock_data.dart';
import 'package:green_garden/main.dart';
import 'package:green_garden/router.dart';

Future<void> openForm(WidgetTester tester, String location) async {
  router.go(location);
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

Finder get nameField => find.byType(TextFormField).at(0);
Finder get speciesField => find.byType(TextFormField).at(1);
Finder get intervalField => find.byType(TextFormField).at(2);

Future<void> submitForm(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Blank name and empty interval keep the form open', (
    tester,
  ) async {
    await openForm(tester, '/plants/new');
    await tester.enterText(nameField, '   ');
    await tester.enterText(intervalField, '');
    await submitForm(tester, 'Добавить растение');
    expect(find.text('Введите название растения'), findsOneWidget);
    expect(find.text('Укажите интервал полива'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Новое растение'), findsOneWidget);
  });

  testWidgets('Zero is rejected by the domain rule', (tester) async {
    await openForm(tester, '/plants/new');
    await tester.enterText(nameField, 'Папоротник');
    await tester.enterText(intervalField, '0');
    await submitForm(tester, 'Добавить растение');
    expect(
      find.text('Интервал полива должен быть не меньше 1 дня'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppBar, 'Новое растение'), findsOneWidget);
  });

  testWidgets('Interval input filters letters', (tester) async {
    await openForm(tester, '/plants/new');
    await tester.enterText(intervalField, 'abc');
    expect(
      tester.widget<TextFormField>(intervalField).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<EditableText>(find.byType(EditableText).at(2)).keyboardType,
      TextInputType.number,
    );
  });

  testWidgets(
    'One day and an optional empty species are accepted without changing mock data',
    (tester) async {
      final count = mockPlants.length;
      await openForm(tester, '/plants/new');
      await tester.enterText(nameField, '  Папоротник  ');
      await tester.enterText(intervalField, '1');
      await submitForm(tester, 'Добавить растение');
      expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
      expect(find.text('Сохранено: Папоротник'), findsOneWidget);
      expect(mockPlants.length, count);
      expect(mockPlants.any((plant) => plant.name == 'Папоротник'), isFalse);
    },
  );

  testWidgets(
    'Editing prefills actual field values and updates them when the id changes',
    (tester) async {
      await openForm(tester, '/plants/ficus/edit');
      expect(
        tester.widget<TextFormField>(nameField).controller!.text,
        'Фикус в гостиной',
      );
      expect(
        tester.widget<TextFormField>(speciesField).controller!.text,
        'Ficus elastica',
      );
      expect(tester.widget<TextFormField>(intervalField).controller!.text, '7');
      await tester.enterText(nameField, 'Несохранённое имя');
      router.go('/plants/zz/edit');
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(nameField).controller!.text,
        'Замиокулькас',
      );
      expect(
        tester.widget<TextFormField>(intervalField).controller!.text,
        '14',
      );
    },
  );

  testWidgets('Valid edit returns to details without mutating the plant', (
    tester,
  ) async {
    await openForm(tester, '/plants/ficus/edit');
    await tester.enterText(nameField, 'Фикус у двери');
    await tester.enterText(intervalField, '10');
    await submitForm(tester, 'Сохранить изменения');
    expect(find.widgetWithText(AppBar, 'Карточка растения'), findsOneWidget);
    expect(find.text('Сохранено: Фикус у двери'), findsOneWidget);
    expect(
      mockPlants.firstWhere((plant) => plant.id == 'ficus').name,
      'Фикус в гостиной',
    );
    expect(
      mockPlants
          .firstWhere((plant) => plant.id == 'ficus')
          .wateringIntervalDays,
      7,
    );
  });

  testWidgets('Keyboard done validates and submits the plant form', (
    tester,
  ) async {
    await openForm(tester, '/plants/new');
    await tester.enterText(nameField, 'Базилик');
    await tester.enterText(intervalField, '2');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
