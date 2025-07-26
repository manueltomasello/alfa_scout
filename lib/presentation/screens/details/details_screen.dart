import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alfa_scout/domain/models/pub_auto.dart';
import 'package:alfa_scout/data/user_api_data_source.dart';
import 'package:alfa_scout/presentation/blocs/favorites/favorite_cubit.dart';
import 'package:alfa_scout/domain/models/user_profile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class DetailsScreen extends StatelessWidget {
  final Pub pub;

  const DetailsScreen({super.key, required this.pub});

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoriteCubit>().isFavorite(pub.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(pub.model),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              context.read<FavoriteCubit>().toggleFavorite(pub.id);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pub.imagePaths.isNotEmpty)
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: pub.imagePaths.length,
                itemBuilder: (context, index) {
                  final path = pub.imagePaths[index];

                  final isBase64 = path.length > 100 &&
                      (path.startsWith('/9j/') || path.startsWith('iVBOR'));

                  try {
                    if (isBase64) {
                      final decoded = base64Decode(path);
                      return Image.memory(
                        decoded,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 100),
                      );
                    } else if (path.startsWith('http')) {
                      return Image.network(
                        path,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 100),
                      );
                    } else if (File(path).existsSync()) {
                      return Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 100),
                      );
                    } else {
                      return Image.asset('assets/images/alfa_logo.png', fit: BoxFit.cover);
                    }
                  } catch (_) {
                    return const Center(child: Icon(Icons.broken_image, size: 100));
                  }
                },
              ),
            )
          else
            const Placeholder(fallbackHeight: 250),
          const SizedBox(height: 16),
          Text(
            pub.title,
            style: Theme.of(context).textTheme.headlineMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text('Prezzo: €${pub.price.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          Text('Chilometri: ${pub.km} km'),
          const SizedBox(height: 16),
          Text(pub.description),
          const SizedBox(height: 20),

          // WHATSAPP BUTTON (solo se l'utente ha inserito il numero)
          FutureBuilder<UserProfile?>(
            future: UserApiDataSource.instance.getUserProfile(pub.ownerId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final phone = snapshot.data!.phone;
              if (phone == null || phone.isEmpty) return const SizedBox.shrink();

              final phoneClean = phone.replaceAll('+', '').replaceAll(' ', '');

              return ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('https://wa.me/$phoneClean');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    //ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossibile aprire WhatsApp')),
                    );
                  }
                },
                icon: const FaIcon(FontAwesomeIcons.whatsapp),
                label: const Text('Contatta su WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
