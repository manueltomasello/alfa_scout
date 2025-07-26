import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CarCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const CarCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  bool get _isBase64 =>
      imagePath.length > 100 &&
      (imagePath.startsWith('/9j/') || imagePath.startsWith('iVBOR'));

  Widget _buildImage() {
    try {
      if (_isBase64) {
        final bytes = base64Decode(imagePath);
        return Image.memory(
          bytes,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else if (File(imagePath).existsSync()) {
        return Image.file(
          File(imagePath),
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else {
        return Image.asset(
          'assets/images/alfa_logo.png',
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    } catch (_) {
      return const Icon(Icons.broken_image, size: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: GFCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(0),
        borderRadius: BorderRadius.circular(12),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: _buildImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.carSide, color: Color(0xFF9B111E)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
