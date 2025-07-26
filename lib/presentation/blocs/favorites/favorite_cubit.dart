import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorite_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit() : super(const FavoriteState());

  /// Carica i preferiti dell'utente loggato da Firestore
  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    final favs = List<String>.from(data?['favoriteIds'] ?? []);
    emit(FavoriteState(favoriteIds: favs));
  }

  Future<void> toggleFavorite(String pubId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final current = state.favoriteIds;
    final updated = Set<String>.from(current);

    if (updated.contains(pubId)) {
      updated.remove(pubId);
    } else {
      updated.add(pubId);
    }

    emit(FavoriteState(favoriteIds: updated.toList()));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'favoriteIds': updated.toList()}, SetOptions(merge: true));
  }

  bool isFavorite(String pubId) {
    return state.favoriteIds.contains(pubId);
  }
}





