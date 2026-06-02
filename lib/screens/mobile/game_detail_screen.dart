import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/config/supabase_config.dart';
import 'package:moscow_store/models/game.dart';
import 'package:moscow_store/providers/auth_provider.dart';
import 'package:moscow_store/providers/games_provider.dart';
import 'package:moscow_store/widgets/package_card.dart';
import 'package:moscow_store/widgets/loading_widget.dart';

class GameDetailScreen extends ConsumerWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(packagesProvider(game.id));
    final accountsAsync = ref.watch(accountsProvider(game.id));
    final customer = ref.watch(authProvider).valueOrNull;

    final color = Color(
      int.parse(game.color.replaceFirst('#', '0xFF')),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.card,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(color: color.withOpacity(0.13)),
                child: game.image != null
                    ? CachedNetworkImage(
                        imageUrl: game.image!.startsWith('http')
                            ? game.image!
                            : '${SupabaseConfig.url}${game.image}',
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                game.nameAr,
                style: const TextStyle(
                  color: AppColors.foreground,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: packagesAsync.when(
                data: (packages) {
                  if (packages.isEmpty) {
                    return const SizedBox();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الباقات',
                        style: TextStyle(
                          color: AppColors.foreground,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...packages.map((pkg) => PackageCard(
                        item: pkg,
                        onTap: () {
                          if (customer == null) {
                            _showLoginDialog(context);
                            return;
                          }
                          context.push('/order', extra: {
                            'game': game,
                            'package': pkg,
                          });
                        },
                      )),
                    ],
                  );
                },
                loading: () => const ShimmerList(itemCount: 4),
                error: (_, __) => const SizedBox(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            sliver: SliverToBoxAdapter(
              child: accountsAsync.when(
                data: (accounts) {
                  final active = accounts
                      .where((a) => !a.isSold && a.isActive)
                      .toList();
                  if (active.isEmpty) {
                    return const SizedBox();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الحسابات',
                        style: TextStyle(
                          color: AppColors.foreground,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...active.map((acc) => PackageCard(
                        item: acc,
                        isAccount: true,
                        onTap: () {
                          if (customer == null) {
                            _showLoginDialog(context);
                            return;
                          }
                          context.push('/order', extra: {
                            'game': game,
                            'package': acc,
                          });
                        },
                      )),
                    ],
                  );
                },
                loading: () => const ShimmerList(itemCount: 3),
                error: (_, __) => const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الدخول مطلوب'),
        content: const Text('يجب تسجيل الدخول لإتمام الطلب'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/login');
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }
}
