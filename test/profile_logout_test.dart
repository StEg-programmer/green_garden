import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:green_garden/main.dart';
import 'package:green_garden/router.dart';

Future<void> openProfile(WidgetTester tester) async {
  router.go('/profile');
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

Future<void> requestLogout(WidgetTester tester) async {
  final button = find.widgetWithText(TextButton, 'Выйти из аккаунта');
  await Scrollable.ensureVisible(tester.element(button), alignment: 0.3);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
  expect(find.byType(AlertDialog), findsOneWidget);
}

void main() {
  testWidgets('Cancel closes only the logout dialog and keeps the profile', (
    tester,
  ) async {
    await openProfile(tester);
    await requestLogout(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Остаться'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.widgetWithText(AppBar, 'Мой профиль'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Confirmed logout removes the shell and its back history', (
    tester,
  ) async {
    router.go('/plants/ficus');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await requestLogout(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Выйти'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.widgetWithText(AppBar, 'Вход и регистрация'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(router.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dismissing outside the dialog does not log out', (tester) async {
    await openProfile(tester);
    await requestLogout(tester);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.widgetWithText(AppBar, 'Мой профиль'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('System back dismisses the dialog without leaving the profile', (
    tester,
  ) async {
    await openProfile(tester);
    await requestLogout(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.widgetWithText(AppBar, 'Мой профиль'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
