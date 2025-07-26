import 'package:alfa_scout/domain/models/pub_auto.dart';

enum PubStatus { initial, loading, success, failure }

class PubState {
  final PubStatus status;
  final List<Pub> pubs;
  final String? errorMessage;

  const PubState({
    this.status = PubStatus.initial,
    this.pubs = const [],
    this.errorMessage,
  });

  PubState copyWith({
    PubStatus? status,
    List<Pub>? pubs,
    String? errorMessage,
  }) {
    return PubState(
      status: status ?? this.status,
      pubs: pubs ?? this.pubs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}