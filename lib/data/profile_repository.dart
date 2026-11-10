import 'result.dart';
import 'user_profile.dart';

abstract class ProfileRepository {
  Future<Result<UserProfile>> fetchProfile();
  Future<Result<UserProfile>> update(UserProfile profile);
}
