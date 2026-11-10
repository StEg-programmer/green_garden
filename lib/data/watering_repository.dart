import 'result.dart';
import 'watering_entry.dart';

abstract class WateringRepository {
  Future<Result<List<WateringEntry>>> fetchAll();
  Future<Result<WateringEntry>> fetchById(String id);
  Future<Result<WateringEntry>> create(WateringEntry draft);
  Future<Result<WateringEntry>> update(WateringEntry entry);
  Future<Result<void>> delete(String id);
}
