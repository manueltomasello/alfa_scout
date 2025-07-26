import 'package:alfa_scout/data/pub_api_service.dart';
import 'package:alfa_scout/data/pub_firestore_api_service.dart';

class PubApiDataSource {
  static final PubApiService _firestore = PubFirestoreApiService();

  static PubApiService get instance => _firestore;
}
