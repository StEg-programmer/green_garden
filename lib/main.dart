import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock_failure_controller.dart';
import 'data/mock_repositories.dart';
import 'models/garden_model.dart';
import 'router.dart';

void main() => runApp(createApp());

Widget createApp({MockFailureController? failureController}) {
  final failures = failureController ?? MockFailureController();
  final store = MockGardenStore();
  final plantRepository = MockPlantRepository(store, failures);
  final wateringRepository = MockWateringRepository(store, failures);
  final profileRepository = MockProfileRepository(store, failures);
  return MultiProvider(
    providers: [
      Provider<MockFailureController>.value(value: failures),
      ChangeNotifierProvider(
        create: (_) => GardenModel(
          plantRepository: plantRepository,
          wateringRepository: wateringRepository,
          profileRepository: profileRepository,
        )..load(),
      ),
    ],
    child: const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'GreenGarden',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    ),
    routerConfig: router,
  );
}
