import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moscow_store/models/game.dart';
import 'package:moscow_store/models/package.dart';
import 'package:moscow_store/models/account.dart';
import 'package:moscow_store/services/game_service.dart';

final gameServiceProvider = Provider<GameService>((ref) => GameService());

final gamesProvider = FutureProvider<List<Game>>((ref) async {
  final service = ref.read(gameServiceProvider);
  return service.getGames();
});

final packagesProvider = FutureProvider.family<List<GamePackage>, int>((ref, gameId) async {
  final service = ref.read(gameServiceProvider);
  return service.getPackages(gameId);
});

final accountsProvider = FutureProvider.family<List<GameAccount>, int>((ref, gameId) async {
  final service = ref.read(gameServiceProvider);
  return service.getAccounts(gameId);
});
