import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:green_garden/data/mock_data.dart';
import 'package:green_garden/main.dart';
import 'package:green_garden/router.dart';
import 'package:green_garden/screens/plant_form_screen.dart';
import 'package:green_garden/screens/plants_screen.dart';
import 'package:green_garden/widgets/plant_card.dart';

Future<void> openLocation(WidgetTester tester, String location) async {
  router.go(location);
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Login opens plants without a return to login', (tester) async {
    await openLocation(tester, '/login');
    final loginButton = find.widgetWithText(FilledButton, 'Войти');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
    expect(router.canPop(), isFalse);
  });

  testWidgets('Plant card opens its details and back restores the list', (
    tester,
  ) async {
    await openLocation(tester, '/plants');
    await tester.scrollUntilVisible(
      find.text('Монстера у окна'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(PlantsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Монстера у окна'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Карточка растения'), findsOneWidget);
    expect(find.text('Monstera deliciosa'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
  });

  testWidgets('Every plant id can be opened directly', (tester) async {
    for (final plant in mockPlants) {
      await openLocation(tester, '/plants/${plant.id}');
      expect(find.widgetWithText(AppBar, 'Карточка растения'), findsOneWidget);
      expect(find.text(plant.species), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('New is a form route rather than a plant id', (tester) async {
    await openLocation(tester, '/plants/new');
    expect(find.widgetWithText(AppBar, 'Новое растение'), findsOneWidget);
    expect(
      tester.widget<PlantFormScreen>(find.byType(PlantFormScreen)).plantId,
      isNull,
    );
  });

  testWidgets('Contextual routes resolve the id without extra', (tester) async {
    await openLocation(tester, '/plants/ficus/edit');
    expect(
      find.widgetWithText(AppBar, 'Редактировать растение'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(PlantCard),
        matching: find.text('Фикус в гостиной'),
      ),
      findsOneWidget,
    );
    await openLocation(tester, '/plants/aloe/watering');
    expect(find.widgetWithText(AppBar, 'Журнал полива'), findsOneWidget);
    expect(find.text('Aloe vera'), findsOneWidget);
    await openLocation(tester, '/plants/zz/reminders');
    expect(find.widgetWithText(AppBar, 'Напоминания'), findsOneWidget);
    expect(find.text('Замиокулькас'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Section menu changes the top level destination', (tester) async {
    await openLocation(tester, '/plants');
    await tester.tap(find.byTooltip('Разделы'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Мой профиль'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Мой профиль'), findsOneWidget);
    expect(router.canPop(), isFalse);
    await openLocation(tester, '/watering-log');
    expect(find.widgetWithText(AppBar, 'Журнал полива'), findsOneWidget);
    await openLocation(tester, '/reminders');
    expect(find.widgetWithText(AppBar, 'Напоминания'), findsOneWidget);
  });

  testWidgets('Unknown plant ids return to the plant list', (tester) async {
    await openLocation(tester, '/plants/missing/edit');
    expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unknown routes display a recovery action', (tester) async {
    await openLocation(tester, '/missing');
    expect(find.text('Страница не найдена'), findsOneWidget);
    await tester.tap(find.text('К моим растениям'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
  });
}
