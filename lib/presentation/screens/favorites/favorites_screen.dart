import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alfa_scout/presentation/blocs/favorites/favorite_cubit.dart';
import 'package:alfa_scout/presentation/blocs/favorites/favorite_state.dart';
import 'package:alfa_scout/data/pub_firestore_api_service.dart';
import 'package:alfa_scout/domain/models/pub_auto.dart';
import 'package:alfa_scout/presentation/screens/details/details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferiti')),
      body: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, state) {
          if (state.favoriteIds.isEmpty) {
            return const Center(child: Text('Nessun preferito ancora.'));
          }

          return FutureBuilder<List<Pub>>(
            future: PubFirestoreApiService.instance.getPubs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Errore nel caricamento dei dati.'));
              }

              final pubs = snapshot.data ?? [];
              final favorites = pubs
                  .where((pub) => state.favoriteIds.contains(pub.id))
                  .toList();

              if (favorites.isEmpty) {
                return const Center(child: Text('Nessun preferito trovato.'));
              }

              return ListView.separated(
                itemCount: favorites.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final pub = favorites[index];
                  return ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.red),
                    title: Text(pub.title),
                    subtitle: Text(pub.model),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailsScreen(pub: pub),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


