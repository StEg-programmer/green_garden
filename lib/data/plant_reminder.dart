class PlantReminder {
  final String id;
  final String plantId;
  final DateTime dueAt;
  final bool isCompleted;

  const PlantReminder({
    required this.id,
    required this.plantId,
    required this.dueAt,
    required this.isCompleted,
  });
}
