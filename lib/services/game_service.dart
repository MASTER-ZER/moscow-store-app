import 'package:moscow_store/services/supabase_service.dart';
import 'package:moscow_store/models/game.dart';
import 'package:moscow_store/models/package.dart';
import 'package:moscow_store/models/account.dart';
import 'package:moscow_store/models/course.dart';

class GameService {
  final SupabaseService _supabase = SupabaseService();

  Future<List<Game>> getGames() async {
    final data = await _supabase.getGames();
    return data.map((json) => Game.fromJson(json)).toList();
  }

  Future<List<GamePackage>> getPackages(int gameId) async {
    final data = await _supabase.getPackages(gameId);
    return data.map((json) => GamePackage.fromJson(json)).toList();
  }

  Future<List<GameAccount>> getAccounts(int gameId) async {
    final data = await _supabase.getAccounts(gameId);
    return data.map((json) => GameAccount.fromJson(json)).toList();
  }

  Future<Game?> getGameBySlug(String slug) async {
    final data = await _supabase.getGameBySlug(slug);
    if (data != null) return Game.fromJson(data);
    return null;
  }
}
