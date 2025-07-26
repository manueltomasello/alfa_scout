import 'package:alfa_scout/domain/models/pub_auto.dart';

abstract class PubApiService {
  Future<List<Pub>> getPubs();
  Future<Pub> addPub(Pub pub);
  Future<void> updatePub(Pub pub);
  Future<List<Pub>> getUserPubs(String uid);
  Future<void> deletePub(String id);
}

