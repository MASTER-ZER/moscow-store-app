import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moscow_store/models/customer.dart';
import 'package:moscow_store/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<Customer?>>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<Customer?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Customer? get customer => state.valueOrNull;
  bool get isLoggedIn => customer != null;

  Future<void> login(String phone, String password) async {
    state = const AsyncValue.loading();
    try {
      final customer = await _authService.login(phone, password);
      state = AsyncValue.data(customer);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    String? referralCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final customer = await _authService.register(
        name: name,
        phone: phone,
        password: password,
        referralCode: referralCode,
      );
      state = AsyncValue.data(customer);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}
