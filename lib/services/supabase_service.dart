import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moscow_store/config/supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  // Auth
  Future<AuthResponse> signInWithPhone(String phone, String password) async {
    return client.auth.signInWithPassword(
      email: '$phone@placeholder.com',
      password: password,
    );
  }

  Future<AuthResponse> signUp(String phone, String password, String name) async {
    return client.auth.signUp(
      email: '$phone@placeholder.com',
      password: password,
      data: {'name': name, 'phone': phone},
    );
  }

  Future<void> signOut() => client.auth.signOut();

  // Games
  Future<List<Map<String, dynamic>>> getGames() async {
    final response = await client
        .from('games')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return response as List<Map<String, dynamic>>;
  }

  Future<Map<String, dynamic>?> getGameBySlug(String slug) async {
    final response = await client
        .from('games')
        .select()
        .eq('slug', slug)
        .single();
    return response as Map<String, dynamic>?;
  }

  // Packages
  Future<List<Map<String, dynamic>>> getPackages(int gameId) async {
    final response = await client
        .from('packages')
        .select()
        .eq('game_id', gameId)
        .eq('is_active', true)
        .order('sort_order');
    return response as List<Map<String, dynamic>>;
  }

  // Accounts
  Future<List<Map<String, dynamic>>> getAccounts(int gameId) async {
    final response = await client
        .from('accounts')
        .select()
        .eq('game_id', gameId)
        .eq('is_active', true)
        .eq('is_sold', false);
    return response as List<Map<String, dynamic>>;
  }

  // Orders
  Future<List<Map<String, dynamic>>> getCustomerOrders(int customerId) async {
    final response = await client
        .from('orders')
        .select('*, games!inner(name, name_ar), packages(name, amount)')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return response as List<Map<String, dynamic>>;
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final response = await client.from('orders').insert(data).select().single();
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateOrderStatus(int id, String status) async {
    final response = await client
        .from('orders')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select()
        .single();
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final response = await client
        .from('orders')
        .select('*, games(name, name_ar), packages(name, amount)')
        .order('created_at', ascending: false);
    return response as List<Map<String, dynamic>>;
  }

  // Customers
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final response = await client
        .from('customers')
        .select()
        .order('created_at', ascending: false);
    return response as List<Map<String, dynamic>>;
  }

  Future<Map<String, dynamic>?> getCustomerProfile(int id) async {
    final response = await client
        .from('customers')
        .select()
        .eq('id', id)
        .single();
    return response as Map<String, dynamic>?;
  }

  // Wallet
  Future<List<Map<String, dynamic>>> getWalletTransactions(int customerId) async {
    final response = await client
        .from('wallet_transactions')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return response as List<Map<String, dynamic>>;
  }

  Future<List<Map<String, dynamic>>> getLoyaltyTransactions(int customerId) async {
    final response = await client
        .from('loyalty_transactions')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return response as List<Map<String, dynamic>>;
  }

  // Payment Methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final response = await client
        .from('payment_methods')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return response as List<Map<String, dynamic>>;
  }

  // Settings
  Future<Map<String, String>> getSettings() async {
    final response = await client.from('settings').select();
    final list = response as List<Map<String, dynamic>>;
    return {for (var s in list) s['key'] as String: s['value'] as String};
  }

  // Chat Messages
  Future<List<Map<String, dynamic>>> getChatMessages(int orderId) async {
    final response = await client
        .from('chat_messages')
        .select()
        .eq('order_id', orderId)
        .order('created_at');
    return response as List<Map<String, dynamic>>;
  }

  Future<Map<String, dynamic>> sendChatMessage(Map<String, dynamic> data) async {
    final response = await client.from('chat_messages').insert(data).select().single();
    return response as Map<String, dynamic>;
  }

  // Admin stats
  Future<Map<String, dynamic>> getAdminStats() async {
    final ordersCount = await client.from('orders').select('id', const FetchOptions(count: CountOption.exact));
    final customersCount = await client.from('customers').select('id', const FetchOptions(count: CountOption.exact));
    final todayOrders = await client
        .from('orders')
        .select('id', const FetchOptions(count: CountOption.exact))
        .gte('created_at', DateTime.now().subtract(const Duration(days: 1)).toIso8601String());
    final pendingOrders = await client
        .from('orders')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('status', 'pending');

    return {
      'total_orders': ordersCount.count ?? 0,
      'total_customers': customersCount.count ?? 0,
      'today_orders': todayOrders.count ?? 0,
      'pending_orders': pendingOrders.count ?? 0,
    };
  }

  // Wallet requests
  Future<List<Map<String, dynamic>>> getWalletRequests() async {
    final response = await client
        .from('wallet_requests')
        .select('*, customers(name, phone)')
        .order('created_at', ascending: false);
    return response as List<Map<String, dynamic>>;
  }

  Future<Map<String, dynamic>> updateWalletRequest(int id, String status, {String? adminNotes}) async {
    final response = await client
        .from('wallet_requests')
        .update({'status': status, 'admin_notes': adminNotes, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select()
        .single();
    return response as Map<String, dynamic>;
  }
}
