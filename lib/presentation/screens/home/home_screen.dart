import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alfa_scout/presentation/blocs/pub/pub_cubit.dart';
import 'package:alfa_scout/presentation/blocs/pub/pub_state.dart';
import 'package:alfa_scout/presentation/router/path.dart';
import 'package:alfa_scout/domain/models/car_card.dart';
import 'package:alfa_scout/presentation/blocs/favorites/favorite_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String query = '';

  @override
  void initState() {
    super.initState();
    context.read<PubCubit>().loadPubs();
    context.read<FavoriteCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AlfaScout'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Cerca modello',
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => query = value.trim().toLowerCase()),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<PubCubit, PubState>(
                builder: (context, state) {
                  if (state.status == PubStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == PubStatus.failure) {
                    return Center(child: Text('Errore: ${state.errorMessage}'));
                  }

                  final filtered = state.pubs
                      .where((pub) => pub.model.toLowerCase().contains(query))
                      .toList();

                  if (filtered.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.directions_car, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Nessun annuncio trovato.', style: TextStyle(fontSize: 16)),
                      ],
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<PubCubit>().loadPubs();
                      //ignore: use_build_context_synchronously
                      await context.read<FavoriteCubit>().loadFavorites();
                      if (mounted) {
                        //ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lista aggiornata')),
                        );
                      }
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final pub = filtered[index];
                        return Hero(
                          tag: pub.id,
                          child: CarCard(
                            imagePath: pub.imagePaths.isNotEmpty ? pub.imagePaths.first : '',
                            title: pub.title,
                            onTap: () => context.go('/details/${pub.id}'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add),
        label: const Text('Nuovo annuncio'),
        onPressed: () => context.push(AppPaths.addPub),
      ),
    );
  }
}





