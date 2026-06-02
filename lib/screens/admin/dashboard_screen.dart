import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/services/supabase_service.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = SupabaseService();
  return service.getAdminStats();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'لوحة التحكم',
                    style: TextStyle(
                      color: AppColors.foreground,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  statsAsync.when(
                    data: (stats) => GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      childAspectRatio: 1.8,
                      children: [
                        _StatCard(
                          title: 'إجمالي الطلبات',
                          value: '${stats['total_orders'] ?? 0}',
                          icon: Icons.receipt_long,
                          color: AppColors.primary,
                        ),
                        _StatCard(
                          title: 'الطلبات اليوم',
                          value: '${stats['today_orders'] ?? 0}',
                          icon: Icons.today,
                          color: AppColors.success,
                        ),
                        _StatCard(
                          title: 'قيد الانتظار',
                          value: '${stats['pending_orders'] ?? 0}',
                          icon: Icons.pending_actions,
                          color: AppColors.warning,
                        ),
                        _StatCard(
                          title: 'العملاء',
                          value: '${stats['total_customers'] ?? 0}',
                          icon: Icons.people,
                          color: AppColors.processing,
                        ),
                      ],
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('خطأ: $e'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.card,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
            ),
            child: const Text(
              'Moscow Store',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _SidebarItem(
            icon: Icons.dashboard,
            label: 'الرئيسية',
            selected: true,
            onTap: () => context.go('/admin'),
          ),
          _SidebarItem(
            icon: Icons.sports_esports,
            label: 'الألعاب',
            onTap: () => context.go('/admin/games'),
          ),
          _SidebarItem(
            icon: Icons.inventory_2,
            label: 'الباقات',
            onTap: () => context.go('/admin/packages'),
          ),
          _SidebarItem(
            icon: Icons.receipt_long,
            label: 'الطلبات',
            onTap: () => context.go('/admin/orders'),
          ),
          _SidebarItem(
            icon: Icons.shop,
            label: 'الحسابات',
            onTap: () => context.go('/admin/accounts'),
          ),
          _SidebarItem(
            icon: Icons.people,
            label: 'العملاء',
            onTap: () => context.go('/admin/customers'),
          ),
          _SidebarItem(
            icon: Icons.settings,
            label: 'الإعدادات',
            onTap: () => context.go('/admin/settings'),
          ),
          const Spacer(),
          _SidebarItem(
            icon: Icons.arrow_back,
            label: 'العودة للمتجر',
            onTap: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : null,
          border: selected
              ? Border(right: BorderSide(color: AppColors.primary, width: 3))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.muted,
                size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.mutedForeground,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
