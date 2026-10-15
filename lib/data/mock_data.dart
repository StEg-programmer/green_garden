enum WateringStatus { watered, due }

class Plant {
  final String id;
  final String name;
  final String species;
  final int wateringIntervalDays;
  final String lastWateredLabel;
  final WateringStatus wateringStatus;

  const Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.wateringIntervalDays,
    required this.lastWateredLabel,
    required this.wateringStatus,
  });
}

const mockPlants = <Plant>[
  Plant(
    id: 'monstera',
    name: 'Монстера у окна',
    species: 'Monstera deliciosa',
    wateringIntervalDays: 7,
    lastWateredLabel: '6 октября',
    wateringStatus: WateringStatus.watered,
  ),
  Plant(
    id: 'ficus',
    name: 'Фикус в гостиной',
    species: 'Ficus elastica',
    wateringIntervalDays: 7,
    lastWateredLabel: '29 сентября',
    wateringStatus: WateringStatus.due,
  ),
  Plant(
    id: 'zz',
    name: 'Замиокулькас',
    species: 'Zamioculcas zamiifolia',
    wateringIntervalDays: 14,
    lastWateredLabel: '1 октября',
    wateringStatus: WateringStatus.watered,
  ),
  Plant(
    id: 'peace-lily',
    name: 'Спатифиллум на рабочем столе',
    species: 'Spathiphyllum wallisii',
    wateringIntervalDays: 5,
    lastWateredLabel: '2 октября',
    wateringStatus: WateringStatus.due,
  ),
  Plant(
    id: 'snake-plant',
    name: 'Сансевиерия',
    species: 'Dracaena trifasciata',
    wateringIntervalDays: 14,
    lastWateredLabel: '3 октября',
    wateringStatus: WateringStatus.watered,
  ),
  Plant(
    id: 'pothos',
    name: 'Эпипремнум на книжной полке',
    species: 'Epipremnum aureum',
    wateringIntervalDays: 7,
    lastWateredLabel: '30 сентября',
    wateringStatus: WateringStatus.due,
  ),
  Plant(
    id: 'spider-plant',
    name: 'Хлорофитум',
    species: 'Chlorophytum comosum',
    wateringIntervalDays: 5,
    lastWateredLabel: '5 октября',
    wateringStatus: WateringStatus.watered,
  ),
  Plant(
    id: 'aloe',
    name: 'Алоэ на кухне',
    species: 'Aloe vera',
    wateringIntervalDays: 14,
    lastWateredLabel: '28 сентября',
    wateringStatus: WateringStatus.watered,
  ),
];

class WateringEntry {
  final String dateLabel;
  final String note;

  const WateringEntry({required this.dateLabel, required this.note});
}

class PlantReminder {
  final String title;
  final String dateLabel;
  final bool isCompleted;

  const PlantReminder({
    required this.title,
    required this.dateLabel,
    required this.isCompleted,
  });
}

const mockMonsteraWateringHistory = <WateringEntry>[
  WateringEntry(
    dateLabel: '6 октября',
    note: 'Почва подсохла. Полил и слил лишнюю воду из поддона.',
  ),
  WateringEntry(
    dateLabel: '29 сентября',
    note: 'Полил утром. Новый лист начал разворачиваться.',
  ),
  WateringEntry(
    dateLabel: '22 сентября',
    note: 'Проверил верхний слой почвы перед поливом.',
  ),
  WateringEntry(
    dateLabel: '15 сентября',
    note: 'Полил отстоянной водой комнатной температуры.',
  ),
  WateringEntry(
    dateLabel: '8 сентября',
    note: 'После полива протёр крупные листья от пыли.',
  ),
  WateringEntry(
    dateLabel: '1 сентября',
    note: 'Полил равномерно по краю горшка.',
  ),
  WateringEntry(
    dateLabel: '25 августа',
    note: 'Проверил дренаж. Вода свободно стекает в поддон.',
  ),
  WateringEntry(
    dateLabel: '18 августа',
    note: 'Почва сухая сверху, листья упругие. Обычный полив.',
  ),
];

const mockMonsteraReminders = <PlantReminder>[
  PlantReminder(
    title: 'Полить монстеру',
    dateLabel: '13 октября, 09:00',
    isCompleted: false,
  ),
  PlantReminder(
    title: 'Полить монстеру',
    dateLabel: '20 октября, 09:00',
    isCompleted: false,
  ),
  PlantReminder(
    title: 'Полить монстеру',
    dateLabel: '27 октября, 09:00',
    isCompleted: false,
  ),
  PlantReminder(
    title: 'Полить монстеру',
    dateLabel: '6 октября, 09:00',
    isCompleted: true,
  ),
  PlantReminder(
    title: 'Полить монстеру',
    dateLabel: '29 сентября, 09:00',
    isCompleted: true,
  ),
  PlantReminder(
    title: 'Полить монстеру',
    dateLabel: '22 сентября, 09:00',
    isCompleted: true,
  ),
];

class PlantCareData {
  final List<WateringEntry> history;
  final List<PlantReminder> reminders;

  const PlantCareData({required this.history, required this.reminders});
}

const mockPlantCare = <String, PlantCareData>{
  'monstera': PlantCareData(
    history: mockMonsteraWateringHistory,
    reminders: mockMonsteraReminders,
  ),
  'ficus': PlantCareData(
    history: [
      WateringEntry(
        dateLabel: '29 сентября',
        note: 'Проверил верхний слой почвы и слил воду из поддона.',
      ),
      WateringEntry(
        dateLabel: '22 сентября',
        note: 'Проверил дренажные отверстия перед поливом.',
      ),
      WateringEntry(
        dateLabel: '15 сентября',
        note: 'Использовал воду комнатной температуры.',
      ),
      WateringEntry(
        dateLabel: '8 сентября',
        note: 'После полива проверил поддон.',
      ),
      WateringEntry(
        dateLabel: '1 сентября',
        note: 'Осмотрел листья: без пожелтения.',
      ),
      WateringEntry(
        dateLabel: '25 августа',
        note: 'Проверил влажность почвы перед поливом.',
      ),
    ],
    reminders: [
      PlantReminder(
        title: 'Полить фикус',
        dateLabel: '6 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить фикус',
        dateLabel: '13 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить фикус',
        dateLabel: '20 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить фикус',
        dateLabel: '29 сентября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить фикус',
        dateLabel: '22 сентября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить фикус',
        dateLabel: '15 сентября, 09:00',
        isCompleted: true,
      ),
    ],
  ),

  'zz': PlantCareData(
    history: [
      WateringEntry(
        dateLabel: '1 октября',
        note: 'Грунт просох. Полил умеренно, без застоя воды.',
      ),
      WateringEntry(
        dateLabel: '17 сентября',
        note: 'Проверил дренажные отверстия перед поливом.',
      ),
      WateringEntry(
        dateLabel: '3 сентября',
        note: 'Использовал воду комнатной температуры.',
      ),
      WateringEntry(
        dateLabel: '20 августа',
        note: 'После полива проверил поддон.',
      ),
      WateringEntry(
        dateLabel: '6 августа',
        note: 'Осмотрел листья: без пожелтения.',
      ),
      WateringEntry(
        dateLabel: '23 июля',
        note: 'Проверил влажность почвы перед поливом.',
      ),
    ],
    reminders: [
      PlantReminder(
        title: 'Полить замиокулькас',
        dateLabel: '15 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить замиокулькас',
        dateLabel: '29 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить замиокулькас',
        dateLabel: '12 ноября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить замиокулькас',
        dateLabel: '1 октября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить замиокулькас',
        dateLabel: '17 сентября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить замиокулькас',
        dateLabel: '3 сентября, 09:00',
        isCompleted: true,
      ),
    ],
  ),

  'peace-lily': PlantCareData(
    history: [
      WateringEntry(
        dateLabel: '2 октября',
        note: 'Проверил влажность почвы. Полил отстоянной водой.',
      ),
      WateringEntry(
        dateLabel: '27 сентября',
        note: 'Проверил дренажные отверстия перед поливом.',
      ),
      WateringEntry(
        dateLabel: '22 сентября',
        note: 'Использовал воду комнатной температуры.',
      ),
      WateringEntry(
        dateLabel: '17 сентября',
        note: 'После полива проверил поддон.',
      ),
      WateringEntry(
        dateLabel: '12 сентября',
        note: 'Осмотрел листья: без пожелтения.',
      ),
      WateringEntry(
        dateLabel: '7 сентября',
        note: 'Проверил влажность почвы перед поливом.',
      ),
    ],
    reminders: [
      PlantReminder(
        title: 'Полить спатифиллум',
        dateLabel: '7 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить спатифиллум',
        dateLabel: '12 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить спатифиллум',
        dateLabel: '17 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить спатифиллум',
        dateLabel: '2 октября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить спатифиллум',
        dateLabel: '27 сентября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить спатифиллум',
        dateLabel: '22 сентября, 09:00',
        isCompleted: true,
      ),
    ],
  ),

  'snake-plant': PlantCareData(
    history: [
      WateringEntry(
        dateLabel: '3 октября',
        note: 'Почва просохла. Полил по краю горшка, не в розетку.',
      ),
      WateringEntry(
        dateLabel: '19 сентября',
        note: 'Проверил дренажные отверстия перед поливом.',
      ),
      WateringEntry(
        dateLabel: '5 сентября',
        note: 'Использовал воду комнатной температуры.',
      ),
      WateringEntry(
        dateLabel: '22 августа',
        note: 'После полива проверил поддон.',
      ),
      WateringEntry(
        dateLabel: '8 августа',
        note: 'Осмотрел листья: без пожелтения.',
      ),
      WateringEntry(
        dateLabel: '25 июля',
        note: 'Проверил влажность почвы перед поливом.',
      ),
    ],
    reminders: [
      PlantReminder(
        title: 'Полить сансевиерию',
        dateLabel: '17 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить сансевиерию',
        dateLabel: '31 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить сансевиерию',
        dateLabel: '14 ноября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить сансевиерию',
        dateLabel: '3 октября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить сансевиерию',
        dateLabel: '19 сентября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить сансевиерию',
        dateLabel: '5 сентября, 09:00',
        isCompleted: true,
      ),
    ],
  ),

  'pothos': PlantCareData(
    history: [
      WateringEntry(
        dateLabel: '30 сентября',
        note: 'Полил после проверки верхнего слоя почвы.',
      ),
      WateringEntry(
        dateLabel: '23 сентября',
        note: 'Проверил дренажные отверстия перед поливом.',
      ),
      WateringEntry(
        dateLabel: '16 сентября',
        note: 'Использовал воду комнатной температуры.',
      ),
      WateringEntry(
        dateLabel: '9 сентября',
        note: 'После полива проверил поддон.',
      ),
      WateringEntry(
        dateLabel: '2 сентября',
        note: 'Осмотрел листья: без пожелтения.',
      ),
      WateringEntry(
        dateLabel: '26 августа',
        note: 'Проверил влажность почвы перед поливом.',
      ),
    ],
    reminders: [
      PlantReminder(
        title: 'Полить эпипремнум',
        dateLabel: '7 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить эпипремнум',
        dateLabel: '14 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить эпипремнум',
        dateLabel: '21 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить эпипремнум',
        dateLabel: '30 сентября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить эпипремнум',
        dateLabel: '23 сентября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить эпипремнум',
        dateLabel: '16 сентября, 09:00',
        isCompleted: true,
      ),
    ],
  ),

  'spider-plant': PlantCareData(
    history: [
      WateringEntry(
        dateLabel: '5 октября',
        note: 'Полил равномерно. Убрал лишнюю воду из поддона.',
      ),
      WateringEntry(
        dateLabel: '30 сентября',
        note: 'Проверил дренажные отверстия перед поливом.',
      ),
      WateringEntry(
        dateLabel: '25 сентября',
        note: 'Использовал воду комнатной температуры.',
      ),
      WateringEntry(
        dateLabel: '20 сентября',
        note: 'После полива проверил поддон.',
      ),
      WateringEntry(
        dateLabel: '15 сентября',
        note: 'Осмотрел листья: без пожелтения.',
      ),
      WateringEntry(
        dateLabel: '10 сентября',
        note: 'Проверил влажность почвы перед поливом.',
      ),
    ],
    reminders: [
      PlantReminder(
        title: 'Полить хлорофитум',
        dateLabel: '10 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить хлорофитум',
        dateLabel: '15 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить хлорофитум',
        dateLabel: '20 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить хлорофитум',
        dateLabel: '5 октября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить хлорофитум',
        dateLabel: '30 сентября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить хлорофитум',
        dateLabel: '25 сентября, 09:00',
        isCompleted: true,
      ),
    ],
  ),

  'aloe': PlantCareData(
    history: [
      WateringEntry(
        dateLabel: '28 сентября',
        note: 'Грунт полностью просох. Полил небольшим количеством воды.',
      ),
      WateringEntry(
        dateLabel: '14 сентября',
        note: 'Проверил дренажные отверстия перед поливом.',
      ),
      WateringEntry(
        dateLabel: '31 августа',
        note: 'Использовал воду комнатной температуры.',
      ),
      WateringEntry(
        dateLabel: '17 августа',
        note: 'После полива проверил поддон.',
      ),
      WateringEntry(
        dateLabel: '3 августа',
        note: 'Осмотрел листья: без пожелтения.',
      ),
      WateringEntry(
        dateLabel: '20 июля',
        note: 'Проверил влажность почвы перед поливом.',
      ),
    ],
    reminders: [
      PlantReminder(
        title: 'Полить алоэ',
        dateLabel: '12 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить алоэ',
        dateLabel: '26 октября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить алоэ',
        dateLabel: '9 ноября, 09:00',
        isCompleted: false,
      ),
      PlantReminder(
        title: 'Полить алоэ',
        dateLabel: '28 сентября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить алоэ',
        dateLabel: '14 сентября, 09:00',
        isCompleted: true,
      ),
      PlantReminder(
        title: 'Полить алоэ',
        dateLabel: '31 августа, 09:00',
        isCompleted: true,
      ),
    ],
  ),
};

class UserProfile {
  final String name;
  final String email;
  final String initials;
  final String joinedLabel;

  const UserProfile({
    required this.name,
    required this.email,
    required this.initials,
    required this.joinedLabel,
  });
}

const mockUser = UserProfile(
  name: 'Егор Ставилов',
  email: 'egor.stavilov@example.com',
  initials: 'ES',
  joinedLabel: 'Сентябрь 2026',
);
