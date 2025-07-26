import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alfa_scout/presentation/blocs/pub/pub_cubit.dart';
import 'package:alfa_scout/presentation/screens/details/details_screen.dart';

class DetailsLoaderScreen extends StatelessWidget {
  final String pubId;

  const DetailsLoaderScreen({super.key, required this.pubId});

  @override
  Widget build(BuildContext context) {
    final pub = context.read<PubCubit>().getPubById(pubId);
    if (pub.id == '') {
      return const Scaffold(
        body: Center(child: Text('Annuncio non trovato')),
      );
    }
    return DetailsScreen(pub: pub);
  }
}