import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moscow_store/models/order.dart';
import 'package:moscow_store/services/order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

final myOrdersProvider = FutureProvider.family<List<Order>, int>((ref, customerId) async {
  final service = ref.read(orderServiceProvider);
  return service.getMyOrders(customerId);
});

final allOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final service = ref.read(orderServiceProvider);
  return service.getAllOrders();
});
