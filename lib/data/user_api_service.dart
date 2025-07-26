import 'package:alfa_scout/domain/models/user_profile.dart';

abstract class UserApiService {
  Future<void> saveUserProfile(UserProfile profile);
  Future<UserProfile?> getUserProfile(String uid);
}
