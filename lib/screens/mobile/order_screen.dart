import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moscow_store/config/theme.dart';
import 'package:moscow_store/models/game.dart';
import 'package:moscow_store/models/package.dart';
import 'package:moscow_store/models/account.dart';
import 'package:moscow_store/providers/auth_provider.dart';
import 'package:moscow_store/providers/orders_provider.dart';
import 'package:moscow_store/services/order_service.dart';

class OrderScreen extends ConsumerStatefulWidget {
  final Game game;
  final dynamic package;

  const OrderScreen({
    super.key,
    required this.game,
    required this.package,
  });

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final _playerIdController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();

  String _loginType = 'id';
  String _paymentMethod = 'wallet';
  bool _loading = false;
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _loadingMethods = true;

  bool get _isAccount => widget.package is GameAccount;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _playerIdController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final service = OrderService();
      final methods = await service.getAllOrders(); // placeholder
    } catch (_) {}
  }

  double get _price {
    if (_isAccount) {
      return (widget.package as GameAccount).price;
    }
    return (widget.package as GamePackage).price;
  }

  Future<void> _submitOrder() async {
    if (!_isAccount && _loginType == 'id' && _playerIdController.text.trim().isEmpty) {
      _showError('يرجى إدخال معرّف اللاعب');
      return;
    }

    setState(() => _loading = true);

    try {
      final customer = ref.read(authProvider).valueOrNull;
      if (customer == null) {
        _showError('يجب تسجيل الدخول أولاً');
        return;
      }

      final orderService = ref.read(orderServiceProvider);

      if (_paymentMethod == 'wallet') {
        await orderService.createWalletOrder(
          customerId: customer.id,
          customerName: customer.name,
          customerPhone: customer.phone,
          gameId: widget.game.id,
          packageId: _isAccount ? null : (widget.package as GamePackage).id,
          accountId: _isAccount ? (widget.package as GameAccount).id : null,
          orderType: _isAccount ? 'account' : 'topup',
          loginType: _isAccount ? null : _loginType,
          playerId: _isAccount ? null : _playerIdController.text.trim(),
          accountUsername: _loginType == 'account' ? _usernameController.text.trim() : null,
          accountPassword: _loginType == 'account' ? _passwordController.text.trim() : null,
          totalAmount: _price,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      } else {
        await orderService.createOrder(
          customerId: customer.id,
          customerName: customer.name,
          customerPhone: customer.phone,
          gameId: widget.game.id,
          packageId: _isAccount ? null : (widget.package as GamePackage).id,
          accountId: _isAccount ? (widget.package as GameAccount).id : null,
          orderType: _isAccount ? 'account' : 'topup',
          loginType: _isAccount ? null : _loginType,
          playerId: _isAccount ? null : _playerIdController.text.trim(),
          accountUsername: _loginType == 'account' ? _usernameController.text.trim() : null,
          accountPassword: _loginType == 'account' ? _passwordController.text.trim() : null,
          paymentMethod: _paymentMethod,
          totalAmount: _price,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('تم إرسال الطلب ✅'),
            content: const Text('سيتم معالجة طلبك في أقرب وقت'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/my-orders');
                },
                child: const Text('عرض طلباتي'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('تفاصيل الطلب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _SummaryRow(label: 'اللعبة', value: widget.game.nameAr),
                  if (!_isAccount)
                    _SummaryRow(
                      label: 'الباقة',
                      value: '${(widget.package as GamePackage).name} - ${(widget.package as GamePackage).amount ?? ''}',
                    ),
                  _SummaryRow(
                    label: 'السعر',
                    value: '$_price ج',
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!_isAccount) ...[
              const Text(
                'معلومات الحساب',
                style: TextStyle(
                  color: AppColors.foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              if (widget.game.loginType == 'both' ||
                  widget.game.loginType == 'id' ||
                  widget.game.loginType == 'account') ...[
                Row(
                  children: [
                    Expanded(
                      child: _LoginTab(
                        label: 'بالـ ID',
                        selected: _loginType == 'id',
                        onTap: () => setState(() => _loginType = 'id'),
                      ),
                    ),
                    if (widget.game.loginType == 'both' ||
                        widget.game.loginType == 'account')
                      Expanded(
                        child: _LoginTab(
                          label: 'بالحساب',
                          selected: _loginType == 'account',
                          onTap: () =>
                              setState(() => _loginType = 'account'),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (_loginType == 'id')
                TextField(
                  controller: _playerIdController,
                  decoration: const InputDecoration(
                    labelText: 'معرّف اللاعب (Player ID)',
                    hintText: 'أدخل معرّف اللاعب',
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                )
              else ...[
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم',
                    hintText: 'اسم المستخدم أو البريد',
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    hintText: 'كلمة المرور',
                  ),
                  obscureText: true,
                  textAlign: TextAlign.right,
                ),
              ],
              const SizedBox(height: 20),
            ],
            const Text(
              'طريقة الدفع',
              style: TextStyle(
                color: AppColors.foreground,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              icon: Icons.account_balance_wallet,
              title: 'المحفظة الإلكترونية',
              subtitle: 'رصيدك: ${customer?.balance ?? 0} ج',
              selected: _paymentMethod == 'wallet',
              onTap: () => setState(() => _paymentMethod = 'wallet'),
            ),
            _PaymentOption(
              icon: Icons.payments,
              title: 'تحويل بنكي / إنستاباي',
              selected: _paymentMethod == 'bank',
              onTap: () => setState(() => _paymentMethod = 'bank'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                hintText: 'أي تعليمات إضافية...',
              ),
              maxLines: 3,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitOrder,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('تأكيد الطلب - $_price ج'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
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
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.foreground,
              fontSize: 14,
              fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LoginTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.13) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: selected
              ? Border.all(color: AppColors.primary.withOpacity(0.25))
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.muted,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.06) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.foreground,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.muted,
                  width: 2,
                ),
                color: selected ? AppColors.primary : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
