import 'date_helpers.dart';
import 'plant.dart';
import 'user_profile.dart';
import 'watering_entry.dart';

final _today = dateOnly(DateTime.now());
final seedPlants = List<Plant>.unmodifiable([
  Plant(
    id: 'monstera',
    name: 'Монстера у окна',
    species: 'Monstera deliciosa',
    wateringIntervalDays: 7,
    createdAt: _today.subtract(const Duration(days: 150)),
  ),
  Plant(
    id: 'ficus',
    name: 'Фикус в гостиной',
    species: 'Ficus elastica',
    wateringIntervalDays: 7,
    createdAt: _today.subtract(const Duration(days: 150)),
  ),
  Plant(
    id: 'zz',
    name: 'Замиокулькас',
    species: 'Zamioculcas zamiifolia',
    wateringIntervalDays: 14,
    createdAt: _today.subtract(const Duration(days: 150)),
  ),
  Plant(
    id: 'peace-lily',
    name: 'Спатифиллум на рабочем столе',
    species: 'Spathiphyllum wallisii',
    wateringIntervalDays: 5,
    createdAt: _today.subtract(const Duration(days: 150)),
  ),
  Plant(
    id: 'snake-plant',
    name: 'Сансевиерия',
    species: 'Dracaena trifasciata',
    wateringIntervalDays: 14,
    createdAt: _today.subtract(const Duration(days: 150)),
  ),
  Plant(
    id: 'pothos',
    name: 'Эпипремнум на книжной полке',
    species: 'Epipremnum aureum',
    wateringIntervalDays: 7,
    createdAt: _today.subtract(const Duration(days: 150)),
  ),
  Plant(
    id: 'spider-plant',
    name: 'Хлорофитум',
    species: 'Chlorophytum comosum',
    wateringIntervalDays: 5,
    createdAt: _today.subtract(const Duration(days: 150)),
  ),
  Plant(
    id: 'aloe',
    name: 'Алоэ на кухне',
    species: 'Aloe vera',
    wateringIntervalDays: 14,
    createdAt: _today.subtract(const Duration(days: 150)),
  ),
]);

const _lastWateredDaysAgo = [1, 8, 6, 5, 4, 7, 2, 9];
const _notes = [
  'Почва подсохла. Полил и слил лишнюю воду из поддона.',
  'Использовал отстоянную воду комнатной температуры.',
  'Проверил верхний слой почвы перед поливом.',
  'Осмотрел листья: без пожелтения.',
  'После полива проверил поддон.',
  'Проверил дренажные отверстия.',
  'Протёр крупные листья от пыли.',
  'Обычный полив после проверки влажности почвы.',
];

final seedWaterings = List<WateringEntry>.unmodifiable([
  for (var p = 0; p < seedPlants.length; p++)
    for (var entry = 0; entry < (p == 0 ? 8 : 6); entry++)
      WateringEntry(
        id: 'seed-$p-$entry',
        plantId: seedPlants[p].id,
        wateredAt: _today.subtract(
          Duration(
            days:
                _lastWateredDaysAgo[p] +
                entry * seedPlants[p].wateringIntervalDays,
          ),
        ),
        note: _notes[entry],
      ),
]);

final seedProfile = UserProfile(
  name: 'Егор Ставилов',
  email: 'egor.stavilov@example.com',
  joinedAt: DateTime(2026, 9, 1),
);
