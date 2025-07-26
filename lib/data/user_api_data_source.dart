import 'package:alfa_scout/data/user_api_service.dart';
import 'package:alfa_scout/data/user_firestore_api_service.dart';

class UserApiDataSource {
  static final UserApiService _firestore = UserFirestoreApiService();

  static UserApiService get instance => _firestore;
}
