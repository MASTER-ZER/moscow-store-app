import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const StatusBadge({super.key, required this.status, this.label = ''});

  @override
  Widget build(BuildContext context) {
    final Map<String, Color> colors = {
      'pending': const Color(0xFFF59E0B),
      'processing': const Color(0xFF3B82F6),
      'completed': const Color(0xFF22C55E),
      'cancelled': const Color(0xFFEF4444),
    };

    final color = colors[status] ?? const Color(0xFF6B7280);
    final displayLabel =
        label.isNotEmpty ? label : _defaultLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _defaultLabel(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'processing':
        return 'جاري التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
