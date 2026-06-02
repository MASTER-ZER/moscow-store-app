import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/services/supabase_service.dart';
import 'package:moscow_store/models/package.dart';

class PackagesAdminScreen extends ConsumerStatefulWidget {
  const PackagesAdminScreen({super.key});

  @override
  ConsumerState<PackagesAdminScreen> createState() => _PackagesAdminScreenState();
}

class _PackagesAdminScreenState extends ConsumerState<PackagesAdminScreen> {
  List<GamePackage> _packages = [];
  List<Map<String, dynamic>> _games = [];
  bool _loading = true;
  int? _selectedGameId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final supabase = SupabaseService();
      final gamesData = await supabase.client.from('games').select().order('sort_order');
      _games = (gamesData as List).cast<Map<String, dynamic>>();

      if (_games.isNotEmpty && _selectedGameId == null) {
        _selectedGameId = _games.first['id'] as int;
      }

      if (_selectedGameId != null) {
        final packagesData = await supabase.getPackages(_selectedGameId!);
        _packages = packagesData.map((j) => GamePackage.fromJson(j)).toList();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                      const Text('إدارة الباقات',
                          style: TextStyle(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold)),
                      Row(children: [
                        DropdownButton<int>(
                          value: _selectedGameId,
                          dropdownColor: AppColors.card,
                          style: const TextStyle(color: AppColors.foreground),
                          underline: const SizedBox(),
                          items: _games.map((g) => DropdownMenuItem(
                            value: g['id'] as int,
                            child: Text(g['name_ar'] as String),
                          )).toList(),
                          onChanged: (v) {
                            setState(() => _selectedGameId = v);
                            _loadData();
                          },
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showPackageDialog(),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('إضافة باقة'),
                        ),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _packages.length,
                        itemBuilder: (_, i) {
                          final pkg = _packages[i];
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
                                    Text(pkg.name, style: const TextStyle(color: AppColors.foreground, fontSize: 15, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('${pkg.amount ?? ''} — ${pkg.price} ج${pkg.hasDiscount ? ' (كان $pkg.originalPrice)' : ''}',
                                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: pkg.isActive,
                                onChanged: (_) async {
                                  final supabase = SupabaseService();
                                  await supabase.client.from('packages').update({'is_active': !pkg.isActive}).eq('id', pkg.id);
                                  _loadData();
                                },
                                activeColor: AppColors.primary,
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primary, size: 18),
                                onPressed: () => _showPackageDialog(package: pkg),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.danger, size: 18),
                                onPressed: () async {
                                  final supabase = SupabaseService();
                                  await supabase.client.from('packages').delete().eq('id', pkg.id);
                                  _loadData();
                                },
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

  void _showPackageDialog({GamePackage? package}) {
    final nameCtrl = TextEditingController(text: package?.name ?? '');
    final amountCtrl = TextEditingController(text: package?.amount ?? '');
    final priceCtrl = TextEditingController(text: package?.price.toString() ?? '');
    final originalPriceCtrl = TextEditingController(text: package?.originalPrice?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(package != null ? 'تعديل باقة' : 'إضافة باقة'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الباقة')),
            const SizedBox(height: 12),
            TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'الكمية')),
            const SizedBox(height: 12),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: originalPriceCtrl, decoration: const InputDecoration(labelText: 'السعر الأصلي (اختياري)'), keyboardType: TextInputType.number),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () async {
            final supabase = SupabaseService();
            final data = {
              'game_id': _selectedGameId,
              'name': nameCtrl.text,
              'amount': amountCtrl.text.isEmpty ? null : amountCtrl.text,
              'price': double.parse(priceCtrl.text),
              'original_price': originalPriceCtrl.text.isEmpty ? null : double.parse(originalPriceCtrl.text),
            };
            if (package != null) {
              await supabase.client.from('packages').update(data).eq('id', package.id);
            } else {
              await supabase.client.from('packages').insert(data);
            }
            Navigator.of(ctx).pop();
            _loadData();
          }, child: const Text('حفظ')),
        ],
      ),
    );
  }

  Widget _buildSidebar() => const _AdminSidebar();
}
