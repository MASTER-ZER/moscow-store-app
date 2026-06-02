import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/services/supabase_service.dart';
import 'package:moscow_store/models/account.dart';

class AccountsAdminScreen extends ConsumerStatefulWidget {
  const AccountsAdminScreen({super.key});

  @override
  ConsumerState<AccountsAdminScreen> createState() => _AccountsAdminScreenState();
}

class _AccountsAdminScreenState extends ConsumerState<AccountsAdminScreen> {
  List<GameAccount> _accounts = [];
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
        final data = await supabase.getAccounts(_selectedGameId!);
        _accounts = data.map((j) => GameAccount.fromJson(j)).toList();
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
                      const Text('إدارة الحسابات',
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
                          onPressed: () => _showAccountDialog(),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('إضافة حساب'),
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
                        itemCount: _accounts.length,
                        itemBuilder: (_, i) {
                          final acc = _accounts[i];
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
                                    Text(acc.title, style: const TextStyle(color: AppColors.foreground, fontSize: 15, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('${acc.price} ج${acc.rank != null ? ' | ${acc.rank}' : ''}${acc.isSold ? ' | تم البيع' : ''}',
                                        style: const TextStyle(color: acc.isSold ? AppColors.danger : AppColors.mutedForeground, fontSize: 13)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primary, size: 18),
                                onPressed: () => _showAccountDialog(account: acc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.danger, size: 18),
                                onPressed: () async {
                                  final supabase = SupabaseService();
                                  await supabase.client.from('accounts').delete().eq('id', acc.id);
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

  void _showAccountDialog({GameAccount? account}) {
    final titleCtrl = TextEditingController(text: account?.title ?? '');
    final priceCtrl = TextEditingController(text: account?.price.toString() ?? '');
    final rankCtrl = TextEditingController(text: account?.rank ?? '');
    final descCtrl = TextEditingController(text: account?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(account != null ? 'تعديل حساب' : 'إضافة حساب'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'العنوان')),
            const SizedBox(height: 12),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: rankCtrl, decoration: const InputDecoration(labelText: 'الرتبة')),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'الوصف'), maxLines: 3),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () async {
            final supabase = SupabaseService();
            final data = {
              'game_id': _selectedGameId,
              'title': titleCtrl.text,
              'price': double.parse(priceCtrl.text),
              'rank': rankCtrl.text.isEmpty ? null : rankCtrl.text,
              'description': descCtrl.text.isEmpty ? null : descCtrl.text,
            };
            if (account != null) {
              await supabase.client.from('accounts').update(data).eq('id', account.id);
            } else {
              await supabase.client.from('accounts').insert(data);
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
