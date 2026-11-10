class WateringEntry {
  final String id;
  final String plantId;
  final DateTime wateredAt;
  final String note;

  const WateringEntry({
    required this.id,
    required this.plantId,
    required this.wateredAt,
    required this.note,
  });

  WateringEntry copyWith({
    String? id,
    String? plantId,
    DateTime? wateredAt,
    String? note,
  }) => WateringEntry(
    id: id ?? this.id,
    plantId: plantId ?? this.plantId,
    wateredAt: wateredAt ?? this.wateredAt,
    note: note ?? this.note,
  );
}
