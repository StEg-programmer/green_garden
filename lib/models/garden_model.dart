import 'package:flutter/foundation.dart';

import '../data/date_helpers.dart';
import '../data/plant.dart';
import '../data/plant_reminder.dart';
import '../data/plant_repository.dart';
import '../data/profile_repository.dart';
import '../data/result.dart';
import '../data/user_profile.dart';
import '../data/watering_entry.dart';
import '../data/watering_repository.dart';

class GardenModel extends ChangeNotifier {
  final PlantRepository _plantRepository;
  final WateringRepository _wateringRepository;
  final ProfileRepository _profileRepository;
  List<Plant> _plants = [];
  List<WateringEntry> _waterings = [];
  UserProfile? _profile;
  bool _loading = false;
  bool _saving = false;
  bool _disposed = false;
  String? _error;

  GardenModel({
    required this._plantRepository,
    required this._wateringRepository,
    required this._profileRepository,
  });

  List<Plant> get plants => List.unmodifiable(_plants);
  List<WateringEntry> get waterings {
    final sorted = List<WateringEntry>.of(_waterings)
      ..sort((a, b) => b.wateredAt.compareTo(a.wateredAt));
    return List.unmodifiable(sorted);
  }

  UserProfile? get profile => _profile;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;

  Plant? byId(String id) {
    for (final plant in _plants) {
      if (plant.id == id) return plant;
    }
    return null;
  }

  WateringEntry? wateringById(String id) {
    for (final entry in _waterings) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  List<WateringEntry> historyFor(String plantId) =>
      List.unmodifiable(waterings.where((entry) => entry.plantId == plantId));

  DateTime? lastWateredAt(String plantId) {
    final history = historyFor(plantId);
    return history.isEmpty ? null : history.first.wateredAt;
  }

  DateTime nextWateringAt(Plant plant) =>
      dateOnly(lastWateredAt(plant.id) ?? plant.createdAt)
          .add(Duration(days: plant.wateringIntervalDays, hours: 9));

  WateringStatus statusFor(Plant plant) {
    if (!dateOnly(nextWateringAt(plant)).isAfter(dateOnly(DateTime.now()))) {
      return WateringStatus.due;
    }
    return lastWateredAt(plant.id) == null
        ? WateringStatus.notWatered
        : WateringStatus.watered;
  }

  int get dueCount =>
      _plants.where((plant) => statusFor(plant) == WateringStatus.due).length;

  List<PlantReminder> get reminders {
    final result = <PlantReminder>[
      for (final plant in _plants)
        PlantReminder(
          id: 'next-${plant.id}',
          plantId: plant.id,
          dueAt: nextWateringAt(plant),
          isCompleted: false,
        ),
      for (final entry in _waterings)
        PlantReminder(
          id: entry.id,
          plantId: entry.plantId,
          dueAt: entry.wateredAt,
          isCompleted: true,
        ),
    ];
    result.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return a.isCompleted
          ? b.dueAt.compareTo(a.dueAt)
          : a.dueAt.compareTo(b.dueAt);
    });
    return List.unmodifiable(result);
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    if (_loading || _saving || _disposed) return;
    _loading = true;
    _error = null;
    _emit();
    try {
      final plantsFuture = _plantRepository.fetchAll();
      final wateringsFuture = _wateringRepository.fetchAll();
      final profileFuture = _profileRepository.fetchProfile();
      final results = (
        await plantsFuture,
        await wateringsFuture,
        await profileFuture,
      );
      if (_disposed) return;
      switch (results) {
        case (
          Ok(value: final plants),
          Ok(value: final waterings),
          Ok(value: final profile),
        ):
          _plants = List.of(plants);
          _waterings = List.of(waterings);
          _profile = profile;
        case (Err(:final message), _, _):
          _error = message;
        case (_, Err(:final message), _):
          _error = message;
        case (_, _, Err(:final message)):
          _error = message;
      }
    } catch (_) {
      if (!_disposed) _error = 'Не удалось загрузить сад. Повторите попытку.';
    } finally {
      _loading = false;
      _emit();
    }
  }

  Future<String?> _mutate<T>(
    Future<Result<T>> Function() request,
    void Function(T) apply,
  ) async {
    if (_loading || _saving) return 'Дождитесь завершения текущей операции';
    if (_disposed) return 'Приложение уже закрыто';
    _saving = true;
    _emit();
    try {
      final result = await request();
      if (_disposed) return 'Приложение уже закрыто';
      switch (result) {
        case Ok(:final value):
          apply(value);
          return null;
        case Err(:final message):
          return message;
      }
    } catch (_) {
      return 'Не удалось сохранить изменения. Повторите попытку.';
    } finally {
      _saving = false;
      _emit();
    }
  }

  Future<String?> addPlant(Plant draft) => _mutate(
    () => _plantRepository.create(draft),
    (value) => _plants = [..._plants, value],
  );

  Future<String?> updatePlant(Plant plant) => _mutate(
    () => _plantRepository.update(plant),
    (value) => _plants = [
      for (final item in _plants)
        if (item.id == value.id) value else item,
    ],
  );

  Future<String?> removePlant(String id) =>
      _mutate<void>(() => _plantRepository.delete(id), (_) {
        _plants = _plants.where((plant) => plant.id != id).toList();
        _waterings = _waterings.where((entry) => entry.plantId != id).toList();
      });

  Future<String?> addWatering(WateringEntry draft) => _mutate(
    () => _wateringRepository.create(draft),
    (value) => _waterings = [..._waterings, value],
  );

  Future<String?> updateWatering(WateringEntry entry) => _mutate(
    () => _wateringRepository.update(entry),
    (value) => _waterings = [
      for (final item in _waterings)
        if (item.id == value.id) value else item,
    ],
  );

  Future<String?> removeWatering(String id) => _mutate<void>(
    () => _wateringRepository.delete(id),
    (_) => _waterings = _waterings.where((entry) => entry.id != id).toList(),
  );

  Future<String?> updateProfile(UserProfile profile) => _mutate(
    () => _profileRepository.update(profile),
    (value) => _profile = value,
  );

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
