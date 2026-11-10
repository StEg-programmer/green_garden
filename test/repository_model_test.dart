import 'package:flutter_test/flutter_test.dart';

import 'package:green_garden/data/date_helpers.dart';
import 'package:green_garden/data/mock_failure_controller.dart';
import 'package:green_garden/data/mock_repositories.dart';
import 'package:green_garden/data/plant.dart';
import 'package:green_garden/data/result.dart';
import 'package:green_garden/data/watering_entry.dart';
import 'package:green_garden/models/garden_model.dart';

class Fixture {
  final failures = MockFailureController(latency: Duration.zero);
  final store = MockGardenStore();
  late final plants = MockPlantRepository(store, failures);
  late final waterings = MockWateringRepository(store, failures);
  late final profile = MockProfileRepository(store, failures);
  late final model = GardenModel(
    plantRepository: plants,
    wateringRepository: waterings,
    profileRepository: profile,
  );
}

Plant draft() => Plant(
  id: '',
  name: 'Базилик',
  species: 'Ocimum basilicum',
  wateringIntervalDays: 1,
  createdAt: DateTime.now(),
);

void main() {
  test('Plant repository supplies ids, copies and complete CRUD', () async {
    final f = Fixture();
    final first = (await f.plants.create(draft()) as Ok<Plant>).value;
    final second = (await f.plants.create(draft()) as Ok<Plant>).value;
    expect(first.id, isNotEmpty);
    expect(first.id, isNot(second.id));
    final snapshot = (await f.plants.fetchAll() as Ok<List<Plant>>).value;
    snapshot.clear();
    expect((await f.plants.fetchAll() as Ok<List<Plant>>).value.length, 10);
    expect(
      await f.plants.update(first.copyWith(name: 'Мята')),
      isA<Ok<Plant>>(),
    );
    expect(
      (await f.plants.fetchById(first.id) as Ok<Plant>).value.name,
      'Мята',
    );
    expect(await f.plants.delete(first.id), isA<Ok<void>>());
    expect(await f.plants.fetchById(first.id), isA<Err<Plant>>());
    expect(await f.plants.delete(first.id), isA<Err<void>>());
    expect(await f.plants.update(first), isA<Err<Plant>>());
  });

  test(
    'Watering CRUD checks ownership and cascades with plant deletion',
    () async {
      final f = Fixture();
      final log = (await f.waterings.create(
        WateringEntry(
          id: '',
          plantId: 'ficus',
          wateredAt: DateTime.now(),
          note: 'Новый полив',
        ),
      ) as Ok<WateringEntry>).value;
      expect(
        await f.waterings.update(log.copyWith(note: 'Исправлено')),
        isA<Ok<WateringEntry>>(),
      );
      expect(
        (await f.waterings.fetchById(log.id) as Ok<WateringEntry>).value.note,
        'Исправлено',
      );
      expect(await f.waterings.delete(log.id), isA<Ok<void>>());
      expect(await f.waterings.fetchById(log.id), isA<Err<WateringEntry>>());
      expect(await f.waterings.delete(log.id), isA<Err<void>>());
      expect(
        await f.waterings.create(log.copyWith(id: '', plantId: 'missing')),
        isA<Err<WateringEntry>>(),
      );
      expect(
        await f.waterings.create(
          log.copyWith(wateredAt: DateTime.now().add(const Duration(days: 2))),
        ),
        isA<Err<WateringEntry>>(),
      );
      await f.plants.delete('ficus');
      expect(
        (await f.waterings.fetchAll() as Ok<List<WateringEntry>>).value.where(
          (item) => item.plantId == 'ficus',
        ),
        isEmpty,
      );
    },
  );

  test('Simulated failures affect reads and writes without mutation', () async {
    final f = Fixture();
    f.failures.simulateError = true;
    expect(await f.plants.fetchAll(), isA<Err<List<Plant>>>());
    expect(await f.plants.fetchById('ficus'), isA<Err<Plant>>());
    expect(await f.plants.create(draft()), isA<Err<Plant>>());
    expect(
      await f.plants.update(draft().copyWith(id: 'ficus')),
      isA<Err<Plant>>(),
    );
    expect(await f.plants.delete('ficus'), isA<Err<void>>());
    expect(await f.waterings.fetchAll(), isA<Err<List<WateringEntry>>>());
    expect(await f.profile.fetchProfile(), isA<Err>());
    f.failures.simulateError = false;
    expect((await f.plants.fetchAll() as Ok<List<Plant>>).value.length, 8);
  });

  test('Model publishes loading, error and successful retry', () async {
    final f = Fixture();
    final states = <bool>[];
    f.model.addListener(() => states.add(f.model.isLoading));
    f.failures.simulateError = true;
    await f.model.load();
    expect(f.model.error, isNotNull);
    expect(states, [true, false]);
    f.failures.simulateError = false;
    await f.model.load();
    expect(f.model.error, isNull);
    expect(f.model.plants.length, 8);
    expect(f.model.waterings.length, 50);
    f.model.dispose();
  });

  test('Collections cannot bypass notifications and model creation really persists', () async {
    final f = Fixture();
    await f.model.load();
    expect(() => f.model.plants.clear(), throwsUnsupportedError);
    expect(() => f.model.waterings.clear(), throwsUnsupportedError);
    var notifications = 0;
    f.model.addListener(() => notifications++);
    expect(await f.model.addPlant(draft()), isNull);
    expect(f.model.plants.length, 9);
    expect(notifications, greaterThan(0));
    await f.model.load();
    expect(f.model.plants.length, 9);
    f.model.dispose();
  });

  test(
    'Watering, editing and cancellation recalculate status and reminders',
    () async {
      final f = Fixture();
      await f.model.load();
      final plant = f.model.byId('ficus')!;
      final oldDue = f.model.nextWateringAt(plant);
      expect(f.model.statusFor(plant), WateringStatus.due);
      await f.model.addWatering(
        WateringEntry(
          id: '',
          plantId: plant.id,
          wateredAt: DateTime.now(),
          note: 'Сегодня',
        ),
      );
      final added = f.model.historyFor(plant.id).first;
      expect(f.model.waterings.length, 51);
      expect(f.model.statusFor(plant), WateringStatus.watered);
      expect(
        dateOnly(f.model.nextWateringAt(plant)),
        dateOnly(DateTime.now()).add(const Duration(days: 7)),
      );
      await f.model.updatePlant(plant.copyWith(wateringIntervalDays: 10));
      expect(
        dateOnly(f.model.nextWateringAt(f.model.byId(plant.id)!)),
        dateOnly(DateTime.now()).add(const Duration(days: 10)),
      );
      await f.model.updatePlant(plant);
      await f.model.removeWatering(added.id);
      expect(f.model.nextWateringAt(plant), oldDue);
      expect(f.model.waterings.length, 50);
      f.model.dispose();
    },
  );

  test('Failed submit preserves data, duplicate submits cannot create duplicate records', () async {
    final f = Fixture();
    await f.model.load();
    f.failures.simulateError = true;
    expect(await f.model.addPlant(draft()), isNotNull);
    expect(f.model.plants.length, 8);
    f.failures.simulateError = false;
    final first = f.model.addPlant(draft());
    final second = await f.model.addPlant(draft());
    expect(second, isNotNull);
    expect(await first, isNull);
    expect(f.model.plants.length, 9);
    await f.model.removePlant('monstera');
    expect(f.model.historyFor('monstera'), isEmpty);
    expect(
      f.model.reminders.where((item) => item.plantId == 'monstera'),
      isEmpty,
    );
    f.model.dispose();
  });

  test(
    'Fresh repositories restart from seeds and pending dispose is safe',
    () async {
      final f = Fixture();
      await f.model.load();
      await f.model.addPlant(draft());
      final fresh = Fixture();
      await fresh.model.load();
      expect(fresh.model.plants.length, 8);
      final pending = f.model.load();
      f.model.dispose();
      await pending;
      fresh.model.dispose();
    },
  );
}
