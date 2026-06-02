import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/services/supabase_service.dart';
import 'package:moscow_store/models/game.dart';

class GamesAdminScreen extends ConsumerStatefulWidget {
  const GamesAdminScreen({super.key});

  @override
  ConsumerState<GamesAdminScreen> createState() => _GamesAdminScreenState();
}

class _GamesAdminScreenState extends ConsumerState<GamesAdminScreen> {
  List<Game> _games = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _loading = true);
    try {
      final supabase = SupabaseService();
      final data = await supabase.client
          .from('games')
          .select()
          .order('sort_order');
      _games = (data as List).map((j) => Game.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggleActive(Game game) async {
    final supabase = SupabaseService();
    await supabase.client
        .from('games')
        .update({'is_active': !game.isActive})
        .eq('id', game.id);
    _loadGames();
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
                      const Text(
                        'إدارة الألعاب',
                        style: TextStyle(
                          color: AppColors.foreground,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showGameDialog(),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('إضافة لعبة'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        child: Table(
                          border: TableBorder(
                            horizontalInside: BorderSide(color: AppColors.cardBorder.withOpacity(0.3)),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(1),
                            4: FlexColumnWidth(1),
                            5: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(
                              children: [
                                _HeaderCell('id'),
                                _HeaderCell('الاسم'),
                                _HeaderCell('الاسم (إنجليزي)'),
                                _HeaderCell('نشط'),
                                _HeaderCell('الترتيب'),
                                _HeaderCell('إجراءات'),
                              ],
                            ),
                            ..._games.map((game) => TableRow(
                              children: [
                                _DataCell('${game.id}'),
                                _DataCell(game.nameAr),
                                _DataCell(game.name),
                                _DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Switch(
                                        value: game.isActive,
                                        onChanged: (_) => _toggleActive(game),
                                        activeColor: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                                _DataCell('${game.sortOrder}'),
                                _DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: AppColors.primary, size: 18),
                                        onPressed: () => _showGameDialog(game: game),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: AppColors.danger, size: 18),
                                        onPressed: () => _deleteGame(game),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                          ],
                        ),
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

  void _showGameDialog({Game? game}) {
    final nameCtrl = TextEditingController(text: game?.name ?? '');
    final nameArCtrl = TextEditingController(text: game?.nameAr ?? '');
    final slugCtrl = TextEditingController(text: game?.slug ?? '');
    final descCtrl = TextEditingController(text: game?.description ?? '');
    final colorCtrl = TextEditingController(text: game?.color ?? '#00B3E5');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(game != null ? 'تعديل لعبة' : 'إضافة لعبة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم (إنجليزي)')),
              const SizedBox(height: 12),
              TextField(controller: nameArCtrl, decoration: const InputDecoration(labelText: 'الاسم (عربي)')),
              const SizedBox(height: 12),
              TextField(controller: slugCtrl, decoration: const InputDecoration(labelText: 'Slug')),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'الوصف'), maxLines: 3),
              const SizedBox(height: 12),
              TextField(controller: colorCtrl, decoration: const InputDecoration(labelText: 'اللون (hex)')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final supabase = SupabaseService();
              final data = {
                'name': nameCtrl.text,
                'name_ar': nameArCtrl.text,
                'slug': slugCtrl.text,
                'description': descCtrl.text,
                'color': colorCtrl.text,
              };
              if (game != null) {
                await supabase.client.from('games').update(data).eq('id', game.id);
              } else {
                await supabase.client.from('games').insert(data);
              }
              Navigator.of(ctx).pop();
              _loadGames();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGame(Game game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف لعبة'),
        content: Text('هل أنت متأكد من حذف ${game.nameAr}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirmed == true) {
      final supabase = SupabaseService();
      await supabase.client.from('games').delete().eq('id', game.id);
      _loadGames();
    }
  }

  Widget _buildSidebar() => const _AdminSidebar();
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('/admin', Icons.dashboard, 'الرئيسية'),
      ('/admin/games', Icons.sports_esports, 'الألعاب', true),
      ('/admin/packages', Icons.inventory_2, 'الباقات'),
      ('/admin/orders', Icons.receipt_long, 'الطلبات'),
      ('/admin/accounts', Icons.shop, 'الحسابات'),
      ('/admin/customers', Icons.people, 'العملاء'),
      ('/admin/settings', Icons.settings, 'الإعدادات'),
    ];

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
            child: const Text('Moscow Store',
                style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          ...items.map((item) => GestureDetector(
            onTap: () => context.go(item.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: item.$3 ? AppColors.primary.withOpacity(0.1) : null,
                border: item.$3
                    ? const Border(right: BorderSide(color: AppColors.primary, width: 3))
                    : null,
              ),
              child: Row(children: [
                Icon(item.$2, color: item.$3 ? AppColors.primary : AppColors.muted, size: 20),
                const SizedBox(width: 12),
                Text(item.$3, style: TextStyle(
                  color: item.$3 ? AppColors.primary : AppColors.mutedForeground,
                  fontSize: 14,
                  fontWeight: item.$3 ? FontWeight.w600 : FontWeight.normal,
                )),
              ]),
            ),
          )),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(label,
          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

class _DataCell extends StatelessWidget {
  final Widget child;
  const _DataCell(this.child);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DefaultTextStyle(
        style: const TextStyle(color: AppColors.foreground, fontSize: 13),
        child: child,
      ),
    );
  }
}
