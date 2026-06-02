import 'package:moscow_store/services/supabase_service.dart';
import 'package:moscow_store/models/order.dart';
import 'package:moscow_store/models/wallet_transaction.dart';

class OrderService {
  final SupabaseService _supabase = SupabaseService();
  int _orderCounter = DateTime.now().millisecondsSinceEpoch;

  Future<Order> createOrder({
    required int customerId,
    required String customerName,
    required String customerPhone,
    required int gameId,
    int? packageId,
    int? accountId,
    int? courseId,
    String orderType = 'topup',
    String? loginType,
    String? playerId,
    String? accountUsername,
    String? accountPassword,
    String? paymentMethod,
    String paymentType = 'transfer',
    required double totalAmount,
    String? notes,
  }) async {
    final orderNumber = 'MOS-${_orderCounter++}';

    final data = {
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'game_id': gameId,
      'package_id': packageId,
      'account_id': accountId,
      'course_id': courseId,
      'order_type': orderType,
      'login_type': loginType,
      'player_id': playerId,
      'account_username': accountUsername,
      'account_password': accountPassword,
      'payment_method': paymentMethod,
      'payment_type': paymentType,
      'total_amount': totalAmount,
      'status': 'pending',
      'notes': notes,
      'source': 'app',
    };

    final result = await _supabase.createOrder(data);
    return Order.fromJson(result);
  }

  Future<Order> createWalletOrder({
    required int customerId,
    required String customerName,
    required String customerPhone,
    required int gameId,
    int? packageId,
    int? accountId,
    String orderType = 'topup',
    String? loginType,
    String? playerId,
    String? accountUsername,
    String? accountPassword,
    required double totalAmount,
    String? notes,
  }) async {
    final customerData = await _supabase.getCustomerProfile(customerId);
    if (customerData == null) throw Exception('العميل غير موجود');

    final balance = (customerData['balance'] as num?)?.toDouble() ?? 0;
    if (balance < totalAmount) throw Exception('رصيد غير كافٍ');

    // Deduct from wallet
    final newBalance = balance - totalAmount;
    await _supabase.client
        .from('customers')
        .update({'balance': newBalance})
        .eq('id', customerId);

    // Record transaction
    await _supabase.client.from('wallet_transactions').insert({
      'customer_id': customerId,
      'type': 'debit',
      'amount': totalAmount,
      'balance_before': balance,
      'balance_after': newBalance,
      'reason': 'طلب #$customerId',
    });

    // Add loyalty points
    final pointsToAdd = (totalAmount / 10).floor();
    if (pointsToAdd > 0) {
      final currentPoints = (customerData['points'] as int?) ?? 0;
      await _supabase.client
          .from('customers')
          .update({'points': currentPoints + pointsToAdd})
          .eq('id', customerId);
      await _supabase.client.from('loyalty_transactions').insert({
        'customer_id': customerId,
        'type': 'credit',
        'points': pointsToAdd,
        'points_before': currentPoints,
        'points_after': currentPoints + pointsToAdd,
        'reason': 'نقاط طلب',
      });
    }

    return createOrder(
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      gameId: gameId,
      packageId: packageId,
      accountId: accountId,
      orderType: orderType,
      loginType: loginType,
      playerId: playerId,
      accountUsername: accountUsername,
      accountPassword: accountPassword,
      paymentMethod: 'wallet',
      paymentType: 'wallet',
      totalAmount: totalAmount,
      notes: notes,
    );
  }

  Future<List<Order>> getMyOrders(int customerId) async {
    final data = await _supabase.getCustomerOrders(customerId);
    return data.map((json) => Order.fromJson(json)).toList();
  }

  Future<List<Order>> getAllOrders() async {
    final data = await _supabase.getAllOrders();
    return data.map((json) => Order.fromJson(json)).toList();
  }

  Future<Order> updateStatus(int orderId, String status) async {
    final data = await _supabase.updateOrderStatus(orderId, status);
    return Order.fromJson(data);
  }
}
