import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/services/supabase_service.dart';

class SettingsAdminScreen extends ConsumerStatefulWidget {
  const SettingsAdminScreen({super.key});

  @override
  ConsumerState<SettingsAdminScreen> createState() => _SettingsAdminScreenState();
}

class _SettingsAdminScreenState extends ConsumerState<SettingsAdminScreen> {
  Map<String, String> _settings = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    try {
      final supabase = SupabaseService();
      _settings = await supabase.getSettings();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _updateSetting(String key, String value) async {
    final supabase = SupabaseService();
    await supabase.client.from('settings').upsert({
      'key': key,
      'value': value,
    });
    setState(() => _settings[key] = value);
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
                  const Text('الإعدادات',
                      style: TextStyle(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Expanded(
                      child: ListView(
                        children: [
                          _SettingItem(
                            label: 'اسم المتجر',
                            value: _settings['store_name'] ?? '',
                            onSave: (v) => _updateSetting('store_name', v),
                          ),
                          _SettingItem(
                            label: 'وصف المتجر',
                            value: _settings['store_description'] ?? '',
                            onSave: (v) => _updateSetting('store_description', v),
                          ),
                          _SettingItem(
                            label: 'رقم الهاتف',
                            value: _settings['contact_phone'] ?? '',
                            onSave: (v) => _updateSetting('contact_phone', v),
                          ),
                          _SettingItem(
                            label: 'البريد الإلكتروني',
                            value: _settings['contact_email'] ?? '',
                            onSave: (v) => _updateSetting('contact_email', v),
                          ),
                          _SettingItem(
                            label: 'حد أدنى للإيداع',
                            value: _settings['min_wallet_deposit'] ?? '10',
                            onSave: (v) => _updateSetting('min_wallet_deposit', v),
                          ),
                          _SettingItem(
                            label: 'معدل نقاط الولاء',
                            value: _settings['loyalty_points_rate'] ?? '10',
                            onSave: (v) => _updateSetting('loyalty_points_rate', v),
                          ),
                          _SettingItem(
                            label: 'نقاط الإحالة',
                            value: _settings['referral_points'] ?? '50',
                            onSave: (v) => _updateSetting('referral_points', v),
                          ),
                          SwitchListTile(
                            title: const Text('وضع الصيانة',
                                style: TextStyle(color: AppColors.foreground)),
                            value: _settings['maintenance_mode'] == 'true',
                            onChanged: (v) => _updateSetting('maintenance_mode', v.toString()),
                            activeColor: AppColors.primary,
                          ),
                        ],
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

class _SettingItem extends StatefulWidget {
  final String label;
  final String value;
  final Function(String) onSave;

  const _SettingItem({required this.label, required this.value, required this.onSave});

  @override
  State<_SettingItem> createState() => _SettingItemState();
}

class _SettingItemState extends State<_SettingItem> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _SettingItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(children: [
        SizedBox(
          width: 150,
          child: Text(widget.label,
              style: const TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(isDense: true),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => widget.onSave(_controller.text),
          child: const Text('حفظ'),
        ),
      ]),
    );
  }
}
