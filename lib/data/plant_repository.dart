import 'plant.dart';
import 'result.dart';

abstract class PlantRepository {
  Future<Result<List<Plant>>> fetchAll();
  Future<Result<Plant>> fetchById(String id);
  Future<Result<Plant>> create(Plant draft);
  Future<Result<Plant>> update(Plant plant);
  Future<Result<void>> delete(String id);
}
