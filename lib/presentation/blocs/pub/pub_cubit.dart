import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alfa_scout/domain/models/pub_auto.dart';
import 'package:alfa_scout/presentation/blocs/pub/pub_state.dart';
import 'package:alfa_scout/data/pub_api_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PubCubit extends Cubit<PubState> {
  PubCubit() : super(const PubState());

  Future<void> loadPubs() async {
    emit(state.copyWith(status: PubStatus.loading));
    try {
      final pubs = await PubApiDataSource.instance.getPubs();
      emit(state.copyWith(status: PubStatus.success, pubs: pubs));
    } catch (e) {
      emit(state.copyWith(status: PubStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> addPub(Pub pub) async {
    try {
      await PubApiDataSource.instance.addPub(pub);
      loadPubs();
    } catch (e) {
      emit(state.copyWith(status: PubStatus.failure, errorMessage: e.toString()));
    }
  }

  Pub getPubById(String id) {
    return state.pubs.firstWhere((p) => p.id == id, orElse: () => Pub(
      id: '',
      title: '',
      model: '',
      description: '',
      price: 0,
      km: 0,
      imagePaths: [],
      ownerId: FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
    ));
  }
}