import 'package:equatable/equatable.dart';

class FavoriteState extends Equatable {
  final List<String> favoriteIds;

  const FavoriteState({this.favoriteIds = const []});

  @override
  List<Object> get props => [favoriteIds];
}




