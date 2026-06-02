import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/services/supabase_service.dart';
import 'package:moscow_store/models/order.dart';
import 'package:moscow_store/widgets/status_badge.dart';

class OrdersAdminScreen extends ConsumerStatefulWidget {
  const OrdersAdminScreen({super.key});

  @override
  ConsumerState<OrdersAdminScreen> createState() => _OrdersAdminScreenState();
}

class _OrdersAdminScreenState extends ConsumerState<OrdersAdminScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    try {
      final supabase = SupabaseService();
      final data = await supabase.getAllOrders();
      _orders = data.map((j) => Order.fromJson(j)).toList();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _updateStatus(Order order, String status) async {
    final supabase = SupabaseService();
    await supabase.updateOrderStatus(order.id, status);
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _statusFilter == 'all'
        ? _orders
        : _orders.where((o) => o.status == _statusFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إدارة الطلبات',
                          style: TextStyle(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold)),
                      Row(children: [
                        _FilterChip(label: 'الكل', selected: _statusFilter == 'all', onTap: () => setState(() => _statusFilter = 'all')),
                        const SizedBox(width: 8),
                        _FilterChip(label: 'قيد الانتظار', selected: _statusFilter == 'pending', onTap: () => setState(() => _statusFilter = 'pending')),
                        const SizedBox(width: 8),
                        _FilterChip(label: 'جاري التنفيذ', selected: _statusFilter == 'processing', onTap: () => setState(() => _statusFilter = 'processing')),
                        const SizedBox(width: 8),
                        _FilterChip(label: 'مكتمل', selected: _statusFilter == 'completed', onTap: () => setState(() => _statusFilter = 'completed')),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final order = filtered[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Text(order.orderNumber,
                                          style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 12),
                                      StatusBadge(status: order.status),
                                    ]),
                                    const SizedBox(height: 6),
                                    Text('${order.gameNameAr ?? ''} | ${order.customerName ?? ''} | ${order.totalAmount} ج',
                                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                                  ],
                                ),
                              ),
                              if (order.status == 'pending')
                                _ActionButton(label: 'قبول', color: AppColors.success, onTap: () => _updateStatus(order, 'processing')),
                              if (order.status == 'processing')
                                _ActionButton(label: 'إكمال', color: AppColors.success, onTap: () => _updateStatus(order, 'completed')),
                              if (order.status == 'pending' || order.status == 'processing')
                                const SizedBox(width: 8),
                              if (order.status == 'pending' || order.status == 'processing')
                                _ActionButton(label: 'إلغاء', color: AppColors.danger, onTap: () => _updateStatus(order, 'cancelled')),
                            ]),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() => const _AdminSidebar();
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.13) : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.primary : AppColors.cardBorder),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? AppColors.primary : AppColors.mutedForeground,
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        )),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
