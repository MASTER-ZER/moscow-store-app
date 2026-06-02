import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/providers/auth_provider.dart';
import 'package:moscow_store/providers/orders_provider.dart';
import 'package:moscow_store/widgets/order_card.dart';
import 'package:moscow_store/widgets/loading_widget.dart';
import 'package:moscow_store/widgets/empty_state.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(authProvider).valueOrNull;

    if (customer == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('طلباتي')),
        body: EmptyState(
          icon: '📦',
          title: 'يجب تسجيل الدخول',
          subtitle: 'سجّل دخولك لعرض طلباتك',
          actionLabel: 'تسجيل الدخول',
          onAction: () => context.push('/login'),
        ),
      );
    }

    final ordersAsync = ref.watch(myOrdersProvider(customer.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('طلباتي')),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return EmptyState(
              icon: '📭',
              title: 'لا توجد طلبات بعد',
              subtitle: 'اطلب أول شحنة الآن',
              actionLabel: 'تصفح الألعاب',
              onAction: () => context.push('/games'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myOrdersProvider(customer.id));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
              children: orders
                  .map((order) => OrderCard(order: order))
                  .toList(),
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(),
        ),
        error: (e, _) => Center(
          child: Text('خطأ: $e',
              style: const TextStyle(color: AppColors.danger)),
        ),
      ),
    );
  }
}
