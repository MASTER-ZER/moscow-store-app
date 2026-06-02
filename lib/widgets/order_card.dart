import 'package:flutter/material.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/models/order.dart';
import 'package:moscow_store/widgets/status_badge.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool showCustomerInfo;

  const OrderCard({
    super.key,
    required this.order,
    this.showCustomerInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                StatusBadge(status: order.status),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _Row(label: 'اللعبة:', value: order.gameNameAr ?? '-'),
                if (order.packageAmount != null)
                  _Row(label: 'الباقة:', value: order.packageAmount!),
                _Row(
                  label: 'المبلغ:',
                  value: '${order.totalAmount} ج',
                  valueColor: AppColors.primary,
                ),
                if (showCustomerInfo && order.customerName != null)
                  _Row(label: 'العميل:', value: order.customerName!),
                _Row(
                  label: 'التاريخ:',
                  value: _formatDate(order.createdAt),
                ),
              ],
            ),
          ),
          if (order.status == 'processing')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.processing.withOpacity(0.08),
                border: Border(
                  top: BorderSide(color: AppColors.processing.withOpacity(0.2)),
                ),
              ),
              child: const Text(
                '🔄 طلبك قيد المعالجة الآن',
                style: TextStyle(color: AppColors.processing, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          if (order.status == 'completed')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                border: Border(
                  top: BorderSide(color: AppColors.success.withOpacity(0.2)),
                ),
              ),
              child: const Text(
                '✅ تم إتمام طلبك بنجاح',
                style: TextStyle(color: AppColors.success, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}/${date.month}/${date.day}';
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.foreground,
              fontSize: 13,
              fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
