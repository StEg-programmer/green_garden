import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:green_garden/data/mock_failure_controller.dart';
import 'package:green_garden/main.dart';
import 'package:green_garden/router.dart';
import 'package:green_garden/screens/plants_screen.dart';

import 'test_support.dart';

void main() {
  testWidgets(
    'Login validates then uses go without keeping login below the shell',
    (tester) async {
      await boot(tester, '/login');
      await press(tester, 'Войти');
      expect(find.text('Введите электронную почту'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await press(tester, 'Войти');
      expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
      expect(router.canPop(), isFalse);
    },
  );

  testWidgets('Data loading is visible before repository response', (
    tester,
  ) async {
    router.go('/plants');
    await tester.pumpWidget(
      createApp(
        failureController: MockFailureController(
          latency: const Duration(seconds: 1),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.textContaining('8 растений'), findsOneWidget);
  });

  testWidgets('Tabs restore a detail and a scrolled plant list', (
    tester,
  ) async {
    await boot(tester, '/plants/ficus');
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Растения'));
    await tester.pumpAndSettle();
    expect(find.text('Ficus elastica'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    final scrollable = find
        .descendant(
          of: find.byType(PlantsScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.drag(scrollable, const Offset(0, -350));
    await tester.pumpAndSettle();
    final offset = tester.state<ScrollableState>(scrollable).position.pixels;
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Растения'));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      closeTo(offset, 0.1),
    );
  });

  testWidgets('Profile switch produces loading error and working retry', (
    tester,
  ) async {
    await boot(tester, '/profile');
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Растения'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Обновить'));
    await tester.pumpAndSettle();
    expect(find.text('Сервер не отвечает — повторите попытку'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Растения'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(find.textContaining('8 растений'), findsOneWidget);
  });

  testWidgets(
    'Missing ids show a message after loading rather than a spinner',
    (tester) async {
      await boot(tester, '/plants/missing');
      expect(find.text('Растение не существует'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await press(tester, 'К моим растениям');
      expect(find.widgetWithText(AppBar, 'Мои растения'), findsOneWidget);
    },
  );
}
