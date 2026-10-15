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
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'anna@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'garden123');
    final loginButton = find.widgetWithText(FilledButton, 'Войти');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
    expect(router.canPop(), isFalse);
    expect(find.text('Вход выполнен'), findsOneWidget);
  });

  testWidgets('Empty login fields show required errors and stay on login', (
    tester,
  ) async {
    await openLocation(tester, '/login');
    final button = find.widgetWithText(FilledButton, 'Войти');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Введите электронную почту'), findsOneWidget);
    expect(
      tester
          .state<FormFieldState<String>>(find.byType(TextFormField).at(1))
          .errorText,
      'Введите пароль',
    );
    expect(find.widgetWithText(AppBar, 'Вход и регистрация'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Invalid email and short password cannot enter the app', (
    tester,
  ) async {
    await openLocation(tester, '/login');
    await tester.enterText(find.byType(TextFormField).at(0), 'anna@');
    await tester.enterText(find.byType(TextFormField).at(1), '12345');
    final button = find.widgetWithText(FilledButton, 'Войти');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(
      find.text('Введите e-mail в формате name@example.com'),
      findsOneWidget,
    );
    expect(
      find.text('Пароль должен содержать минимум 6 символов'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppBar, 'Вход и регистрация'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Any valid credentials enter without a mock user comparison', (
    tester,
  ) async {
    await openLocation(tester, '/login');
    await tester.enterText(
      find.byType(TextFormField).at(0),
      '  another@example.org  ',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'abcdef');
    expect(
      tester.widget<EditableText>(find.byType(EditableText).at(0)).keyboardType,
      TextInputType.emailAddress,
    );
    expect(
      tester.widget<EditableText>(find.byType(EditableText).at(1)).obscureText,
      isTrue,
    );
    final button = find.widgetWithText(FilledButton, 'Войти');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
    expect(router.canPop(), isFalse);
  });

  testWidgets('Keyboard done uses the same login validation', (tester) async {
    await openLocation(tester, '/login');
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'keyboard@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.testTextInput.receiveAction(TextInputAction.done);
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

  testWidgets('Bottom tabs open all main destinations', (tester) async {
    await openLocation(tester, '/plants');
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
    await tester.tap(find.text('Журнал'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Журнал полива'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    await tester.tap(find.text('Напоминания'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Напоминания'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Мой профиль'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
    expect(router.canPop(), isFalse);
  });

  testWidgets('Returning to plants restores the open details', (tester) async {
    await openLocation(tester, '/plants/ficus');
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Растения'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Карточка растения'), findsOneWidget);
    expect(find.text('Ficus elastica'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
  });

  testWidgets('Returning to plants preserves list scroll position', (
    tester,
  ) async {
    await openLocation(tester, '/plants');
    final scrollable = find
        .descendant(
          of: find.byType(PlantsScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.drag(scrollable, const Offset(0, -450));
    await tester.pumpAndSettle();
    final offset = tester.state<ScrollableState>(scrollable).position.pixels;
    expect(offset, greaterThan(0));
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Растения'));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      closeTo(offset, 0.1),
    );
  });

  testWidgets('Forms stay in the plants tab and login has no tabs', (
    tester,
  ) async {
    for (final location in [
      '/plants/new',
      '/plants/aloe/edit',
      '/plants/aloe/watering',
    ]) {
      await openLocation(tester, location);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
    }
    await openLocation(tester, '/login');
    expect(find.byType(NavigationBar), findsNothing);
    expect(router.canPop(), isFalse);
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
