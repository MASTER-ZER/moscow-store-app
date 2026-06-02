import 'package:moscow_store/services/supabase_service.dart';
import 'package:moscow_store/models/payment_method.dart';
import 'package:moscow_store/models/wallet_transaction.dart';

class PaymentService {
  final SupabaseService _supabase = SupabaseService();

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final data = await _supabase.getPaymentMethods();
    return data.map((json) => PaymentMethod.fromJson(json)).toList();
  }

  Future<List<WalletTransaction>> getWalletTransactions(int customerId) async {
    final data = await _supabase.getWalletTransactions(customerId);
    return data.map((json) => WalletTransaction.fromJson(json)).toList();
  }

  Future<Map<String, String>> getSettings() async {
    return _supabase.getSettings();
  }
}
