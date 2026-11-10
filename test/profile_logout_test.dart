import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_garden/router.dart';

import 'test_support.dart';

void main() {
  testWidgets(
    'Logout cancellation preserves profile, confirmation removes shell',
    (tester) async {
      await boot(tester, '/profile');
      await press(tester, 'Выйти из аккаунта');
      await tester.tap(find.text('Остаться'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Мой профиль'), findsOneWidget);
      await press(tester, 'Выйти из аккаунта');
      await tester.tap(find.widgetWithText(FilledButton, 'Выйти'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Вход и регистрация'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(router.canPop(), isFalse);
    },
  );

  testWidgets('Profile editing uses repository and updates the header', (
    tester,
  ) async {
    await boot(tester, '/profile');
    await press(tester, 'Редактировать профиль');
    await tester.enterText(
      find.byType(TextFormField).first,
      'Егор Ставилов Тест',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();
    expect(garden(tester).profile!.name, 'Егор Ставилов Тест');
    expect(find.byType(AlertDialog), findsNothing);
  });
}
