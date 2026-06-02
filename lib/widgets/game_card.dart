import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moscow_store/models/game.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/config/supabase_config.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameCard({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(
      int.parse(game.color.replaceFirst('#', '0xFF')),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(13),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(13),
                  ),
                  child: game.image != null
                      ? CachedNetworkImage(
                          imageUrl: game.image!.startsWith('http')
                              ? game.image!
                              : '${SupabaseConfig.url}${game.image}',
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _Placeholder(game: game, color: color),
                          errorWidget: (_, __, ___) => _Placeholder(game: game, color: color),
                        )
                      : _Placeholder(game: game, color: color),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                game.nameAr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Game game;
  final Color color;
  const _Placeholder({required this.game, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        game.nameAr.isNotEmpty ? game.nameAr[0] : '?',
        style: TextStyle(
          color: color,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
