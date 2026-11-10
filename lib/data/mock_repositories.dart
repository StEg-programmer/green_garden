import 'date_helpers.dart';
import 'mock_data.dart';
import 'mock_failure_controller.dart';
import 'plant.dart';
import 'plant_repository.dart';
import 'profile_repository.dart';
import 'result.dart';
import 'user_profile.dart';
import 'watering_entry.dart';
import 'watering_repository.dart';

class MockGardenStore {
  final List<Plant> _plants = List.of(seedPlants);
  final List<WateringEntry> _waterings = List.of(seedWaterings);
  UserProfile _profile = seedProfile;
  int _nextPlantId = 1000;
  int _nextWateringId = 1000;
}

abstract class _MockRepository {
  final MockGardenStore store;
  final MockFailureController failures;
  _MockRepository(this.store, this.failures);

  Future<Result<T>> request<T>(Result<T> Function() operation) async {
    await Future<void>.delayed(failures.latency);
    if (failures.simulateError) {
      return const Err('Сервер не отвечает — повторите попытку');
    }
    return operation();
  }
}

class MockPlantRepository extends _MockRepository implements PlantRepository {
  MockPlantRepository(super.store, super.failures);

  @override
  Future<Result<List<Plant>>> fetchAll() =>
      request(() => Ok(List.of(store._plants)));

  @override
  Future<Result<Plant>> fetchById(String id) => request(() {
    final index = store._plants.indexWhere((plant) => plant.id == id);
    return index < 0
        ? const Err('Растение не существует')
        : Ok(store._plants[index]);
  });

  @override
  Future<Result<Plant>> create(Plant draft) => request(() {
    if (draft.name.trim().isEmpty || draft.wateringIntervalDays < 1) {
      return const Err('Проверьте название и интервал полива');
    }
    final created = draft.copyWith(id: 'plant-${store._nextPlantId++}');
    store._plants.add(created);
    return Ok(created);
  });

  @override
  Future<Result<Plant>> update(Plant plant) => request(() {
    final index = store._plants.indexWhere((item) => item.id == plant.id);
    if (index < 0) return const Err('Растение не существует');
    if (plant.name.trim().isEmpty || plant.wateringIntervalDays < 1) {
      return const Err('Проверьте название и интервал полива');
    }
    store._plants[index] = plant;
    return Ok(plant);
  });

  @override
  Future<Result<void>> delete(String id) => request<void>(() {
    if (!store._plants.any((plant) => plant.id == id)) {
      return const Err('Растение не существует');
    }
    store._plants.removeWhere((plant) => plant.id == id);
    store._waterings.removeWhere((entry) => entry.plantId == id);
    return const Ok(null);
  });
}

class MockWateringRepository extends _MockRepository
    implements WateringRepository {
  MockWateringRepository(super.store, super.failures);

  String? _validate(WateringEntry entry) {
    if (!store._plants.any((plant) => plant.id == entry.plantId)) {
      return 'Растение не существует';
    }
    if (dateOnly(entry.wateredAt).isAfter(dateOnly(DateTime.now()))) {
      return 'Дата полива не может быть в будущем';
    }
    return null;
  }

  @override
  Future<Result<List<WateringEntry>>> fetchAll() =>
      request(() => Ok(List.of(store._waterings)));

  @override
  Future<Result<WateringEntry>> fetchById(String id) => request(() {
    final index = store._waterings.indexWhere((entry) => entry.id == id);
    return index < 0
        ? const Err('Запись полива не существует')
        : Ok(store._waterings[index]);
  });

  @override
  Future<Result<WateringEntry>> create(WateringEntry draft) => request(() {
    final error = _validate(draft);
    if (error != null) return Err(error);
    final created = draft.copyWith(id: 'watering-${store._nextWateringId++}');
    store._waterings.add(created);
    return Ok(created);
  });

  @override
  Future<Result<WateringEntry>> update(WateringEntry entry) => request(() {
    final index = store._waterings.indexWhere((item) => item.id == entry.id);
    if (index < 0) return const Err('Запись полива не существует');
    final error = _validate(entry);
    if (error != null) return Err(error);
    store._waterings[index] = entry;
    return Ok(entry);
  });

  @override
  Future<Result<void>> delete(String id) => request<void>(() {
    if (!store._waterings.any((entry) => entry.id == id)) {
      return const Err('Запись полива не существует');
    }
    store._waterings.removeWhere((entry) => entry.id == id);
    return const Ok(null);
  });
}

class MockProfileRepository extends _MockRepository
    implements ProfileRepository {
  MockProfileRepository(super.store, super.failures);

  @override
  Future<Result<UserProfile>> fetchProfile() =>
      request(() => Ok(store._profile));

  @override
  Future<Result<UserProfile>> update(UserProfile profile) => request(() {
    if (profile.name.trim().isEmpty || !profile.email.contains('@')) {
      return const Err('Проверьте данные профиля');
    }
    store._profile = profile;
    return Ok(profile);
  });
}
