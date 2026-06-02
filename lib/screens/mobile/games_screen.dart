import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/providers/games_provider.dart';
import 'package:moscow_store/widgets/game_card.dart';
import 'package:moscow_store/widgets/loading_widget.dart';
import 'package:moscow_store/widgets/empty_state.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(gamesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الألعاب')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'ابحث عن لعبة...',
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppColors.muted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: gamesAsync.when(
              data: (games) {
                final filtered = _searchQuery.isEmpty
                    ? games
                    : games.where((g) =>
                        g.nameAr.contains(_searchQuery) ||
                        g.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: '🎮',
                    title: 'لا توجد ألعاب',
                    subtitle: 'ابحث عن لعبة أخرى',
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(11, 0, 11, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => GameCard(
                    game: filtered[i],
                    onTap: () => context.push(
                      '/games/${filtered[i].slug}',
                      extra: filtered[i],
                    ),
                  ),
                );
              },
              loading: () => const ShimmerGrid(),
              error: (e, _) => Center(
                child: Text('خطأ: $e',
                    style: const TextStyle(color: AppColors.danger)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
