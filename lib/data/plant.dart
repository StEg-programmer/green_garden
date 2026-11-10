enum WateringStatus { watered, due, notWatered }

class Plant {
  final String id;
  final String name;
  final String species;
  final int wateringIntervalDays;
  final DateTime createdAt;

  const Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.wateringIntervalDays,
    required this.createdAt,
  });

  Plant copyWith({
    String? id,
    String? name,
    String? species,
    int? wateringIntervalDays,
    DateTime? createdAt,
  }) => Plant(
    id: id ?? this.id,
    name: name ?? this.name,
    species: species ?? this.species,
    wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
    createdAt: createdAt ?? this.createdAt,
  );
}
