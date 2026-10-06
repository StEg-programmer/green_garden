// Статические данные для макета L2. Статус полива задан вручную.
enum WateringStatus { watered, due }

class Plant {
  final String name;
  final String species;
  final int wateringIntervalDays;
  final String lastWateredLabel;
  final WateringStatus wateringStatus;

  const Plant({
    required this.name,
    required this.species,
    required this.wateringIntervalDays,
    required this.lastWateredLabel,
    required this.wateringStatus,
  });
}

const mockPlants = <Plant>[
  Plant(
    name: 'Монстера у окна',
    species: 'Monstera deliciosa',
    wateringIntervalDays: 7,
    lastWateredLabel: '6 октября',
    wateringStatus: WateringStatus.watered,
  ),
  Plant(
    name: 'Фикус в гостиной',
    species: 'Ficus elastica',
    wateringIntervalDays: 7,
    lastWateredLabel: '29 сентября',
    wateringStatus: WateringStatus.due,
  ),
  Plant(
    name: 'Замиокулькас',
    species: 'Zamioculcas zamiifolia',
    wateringIntervalDays: 14,
    lastWateredLabel: '1 октября',
    wateringStatus: WateringStatus.watered,
  ),
  Plant(
    name: 'Спатифиллум на рабочем столе',
    species: 'Spathiphyllum wallisii',
    wateringIntervalDays: 5,
    lastWateredLabel: '2 октября',
    wateringStatus: WateringStatus.due,
  ),
  Plant(
    name: 'Сансевиерия',
    species: 'Dracaena trifasciata',
    wateringIntervalDays: 14,
    lastWateredLabel: '3 октября',
    wateringStatus: WateringStatus.watered,
  ),
  Plant(
    name: 'Эпипремнум на книжной полке',
    species: 'Epipremnum aureum',
    wateringIntervalDays: 7,
    lastWateredLabel: '30 сентября',
    wateringStatus: WateringStatus.due,
  ),
  Plant(
    name: 'Хлорофитум',
    species: 'Chlorophytum comosum',
    wateringIntervalDays: 5,
    lastWateredLabel: '5 октября',
    wateringStatus: WateringStatus.watered,
  ),
  Plant(
    name: 'Алоэ на кухне',
    species: 'Aloe vera',
    wateringIntervalDays: 14,
    lastWateredLabel: '28 сентября',
    wateringStatus: WateringStatus.watered,
  ),
];
