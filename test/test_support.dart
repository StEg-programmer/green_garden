import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:green_garden/data/mock_failure_controller.dart';
import 'package:green_garden/main.dart';
import 'package:green_garden/models/garden_model.dart';
import 'package:green_garden/router.dart';
import 'package:green_garden/widgets/app_shell.dart';

Future<MockFailureController> boot(
  WidgetTester tester,
  String location, {
  Duration latency = Duration.zero,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  router.go(location);
  final failures = MockFailureController(latency: latency);
  await tester.pumpWidget(createApp(failureController: failures));
  await tester.pumpAndSettle();
  return failures;
}

GardenModel garden(WidgetTester tester) =>
    tester.element(find.byType(AppShell)).read<GardenModel>();

Future<void> reveal(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.3);
  await tester.pumpAndSettle();
}

Future<void> press(WidgetTester tester, String label) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
  final finder = find.text(label).last;
  await reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> selectToday(WidgetTester tester) async {
  final field = find.byKey(const ValueKey('watering-date'));
  await reveal(tester, field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Выбрать'));
  await tester.pumpAndSettle();
}
