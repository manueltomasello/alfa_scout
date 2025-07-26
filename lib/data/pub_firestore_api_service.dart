import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:alfa_scout/data/pub_api_service.dart';
import 'package:alfa_scout/domain/models/pub_auto.dart';

class PubFirestoreApiService implements PubApiService {
  final _pubsRef = FirebaseFirestore.instance.collection('pubs');

  @override
  Future<List<Pub>> getPubs() async {
    final snapshot = await _pubsRef.get();
    return snapshot.docs.map((doc) {
      return Pub.fromJson(doc.data()).copyWith(id: doc.id);
    }).toList();
  }

  @override
  Future<Pub> addPub(Pub pub) async {
    final docId = const Uuid().v4();

    // Le immagini sono già in base64
    final pubWithId = pub.copyWith(id: docId);

    await _pubsRef.doc(docId).set(pubWithId.toJson());

    return pubWithId;
  }

  @override
  Future<void> updatePub(Pub pub) async {
    await _pubsRef.doc(pub.id).update(pub.toJson());
  }

  @override
  Future<List<Pub>> getUserPubs(String uid) async {
    final snapshot = await _pubsRef.where('ownerId', isEqualTo: uid).get();
    return snapshot.docs.map((doc) {
      return Pub.fromJson(doc.data()).copyWith(id: doc.id);
    }).toList();
  }

  @override
  Future<void> deletePub(String id) async {
    await _pubsRef.doc(id).delete();
  }

  static final PubFirestoreApiService instance = PubFirestoreApiService();
}




