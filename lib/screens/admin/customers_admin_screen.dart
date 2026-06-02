import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/services/supabase_service.dart';

class CustomersAdminScreen extends ConsumerStatefulWidget {
  const CustomersAdminScreen({super.key});

  @override
  ConsumerState<CustomersAdminScreen> createState() => _CustomersAdminScreenState();
}

class _CustomersAdminScreenState extends ConsumerState<CustomersAdminScreen> {
  List<Map<String, dynamic>> _customers = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _loading = true);
    try {
      final supabase = SupabaseService();
      final data = await supabase.getAllCustomers();
      _customers = data;
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? _customers
        : _customers.where((c) =>
            (c['name'] as String).contains(_searchQuery) ||
            (c['phone'] as String).contains(_searchQuery)).toList();

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
                      const Text('إدارة العملاء',
                          style: TextStyle(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            hintText: 'ابحث عن عميل...',
                            prefixIcon: Icon(Icons.search, size: 20),
                          ),
                        ),
                      ),
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
                          final c = filtered[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    (c['name'] as String).isNotEmpty
                                        ? (c['name'] as String)[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['name'] as String,
                                        style: const TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text('${c['phone']} | رصيد: ${c['balance']} ج | ${c['points']} نقطة',
                                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (c['level'] as String?) == null
                                      ? AppColors.muted.withOpacity(0.13)
                                      : AppColors.primary.withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  (c['level'] as String?) ?? 'starter',
                                  style: TextStyle(
                                    color: (c['level'] as String?) == null
                                        ? AppColors.muted
                                        : AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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
