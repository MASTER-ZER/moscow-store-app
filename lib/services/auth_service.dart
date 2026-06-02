import 'package:moscow_store/services/supabase_service.dart';
import 'package:moscow_store/models/customer.dart';

class AuthService {
  final SupabaseService _supabase = SupabaseService();

  Future<Customer> login(String phone, String password) async {
    final response = await _supabase.signInWithPhone(phone, password);
    final userId = response.user!.id;

    final profileData = await _supabase.client
        .from('customers')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (profileData != null) {
      return Customer.fromJson(profileData as Map<String, dynamic>);
    }

    throw Exception('لم يتم العثور على حساب');
  }

  Future<Customer> register({
    required String name,
    required String phone,
    required String password,
    String? referralCode,
  }) async {
    final response = await _supabase.signUp(phone, password, name);
    final userId = response.user!.id;

    final newCustomer = {
      'id': userId,
      'name': name,
      'phone': phone,
      'password': password,
      'balance': 0,
      'points': 0,
      'level': 'starter',
      'referral_code': _generateReferralCode(),
    };

    if (referralCode != null && referralCode.isNotEmpty) {
      final referrer = await _supabase.client
          .from('customers')
          .select()
          .eq('referral_code', referralCode)
          .maybeSingle();
      if (referrer != null) {
        newCustomer['referred_by'] = (referrer as Map<String, dynamic>)['id'];
      }
    }

    await _supabase.client.from('customers').insert(newCustomer);
    return Customer.fromJson(newCustomer);
  }

  Future<void> logout() async {
    await _supabase.signOut();
  }

  Future<Customer?> getProfile(int id) async {
    final data = await _supabase.getCustomerProfile(id);
    if (data != null) return Customer.fromJson(data);
    return null;
  }

  String _generateReferralCode() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 8; i++) {
      code += chars[(random >> (i * 3)) % chars.length];
    }
    return code;
  }
}
