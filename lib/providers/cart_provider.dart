import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moscow_store/models/game.dart';

class CartState {
  final Game? game;
  final dynamic selectedPackage;
  final String? loginType;
  final String? playerId;
  final String? accountUsername;
  final String? accountPassword;
  final String? paymentMethod;
  final String? notes;

  const CartState({
    this.game,
    this.selectedPackage,
    this.loginType,
    this.playerId,
    this.accountUsername,
    this.accountPassword,
    this.paymentMethod,
    this.notes,
  });

  CartState copyWith({
    Game? game,
    dynamic selectedPackage,
    String? loginType,
    String? playerId,
    String? accountUsername,
    String? accountPassword,
    String? paymentMethod,
    String? notes,
  }) {
    return CartState(
      game: game ?? this.game,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      loginType: loginType ?? this.loginType,
      playerId: playerId ?? this.playerId,
      accountUsername: accountUsername ?? this.accountUsername,
      accountPassword: accountPassword ?? this.accountPassword,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void setGame(Game game) => state = state.copyWith(game: game);
  void setPackage(dynamic pkg) => state = state.copyWith(selectedPackage: pkg);
  void setLoginType(String type) => state = state.copyWith(loginType: type);
  void setPlayerId(String id) => state = state.copyWith(playerId: id);
  void setAccountCredentials(String username, String password) =>
      state = state.copyWith(accountUsername: username, accountPassword: password);
  void setPaymentMethod(String method) => state = state.copyWith(paymentMethod: method);
  void setNotes(String notes) => state = state.copyWith(notes: notes);
  void reset() => state = const CartState();
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) => CartNotifier());
