import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/partner_provider.dart';
import '../../theme.dart';
import '../../widgets/network_or_base64_image.dart';

class PartnerBalanceScreen extends StatelessWidget {
  const PartnerBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partner = context.watch<PartnerProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            // Карточка баланса
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9C94FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  const Text('Доступный баланс', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '₸${partner.balance.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Выручка: ₸${partner.totalRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showWithdrawDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6C63FF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.arrow_upward, size: 18),
                          label: const Text('Вывести', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showHistoryDialog(context, partner),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.history, size: 18),
                          label: const Text('История', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Быстрые метрики
            Row(
              children: [
                Expanded(child: _MetricCard(label: 'Товаров', value: '${partner.products.length}', icon: Icons.inventory_2, color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(label: 'Продаж', value: '${partner.totalSold}', icon: Icons.shopping_bag, color: Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(label: 'Склад', value: '${partner.totalStock}', icon: Icons.warehouse, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 28),

            // Доходы по товарам
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('💵 Доходы по товарам', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            ),
            const SizedBox(height: 16),
            if (partner.products.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.bar_chart, size: 64, color: AppTheme.greyColor.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    const Text('Нет данных о продажах', style: TextStyle(color: AppTheme.greyColor, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text('Добавьте и продавайте товары', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                  ],
                ),
              )
            else
              ...partner.products.map((p) => _IncomeRow(product: p)),
            const SizedBox(height: 16),

            // Итого
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor.withOpacity(0.08), AppTheme.primaryColor.withOpacity(0.15)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('Итого выручка', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textColor)),
                    ],
                  ),
                  Text(
                    '₸${partner.totalRevenue.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('💳', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Вывод средств'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Функция вывода будет доступна после подключения платёжной системы Kaspi / Halyk.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context, PartnerProvider partner) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('📋 История операций', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (partner.transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('Пока нет операций', style: TextStyle(color: AppTheme.greyColor)),
              )
            else
              SizedBox(
                height: 300,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: partner.transactions.length,
                  itemBuilder: (_, i) {
                    final tx = partner.transactions.reversed.toList()[i];
                    return ListTile(
                      leading: Text(tx.typeLabel.substring(0, 2), style: const TextStyle(fontSize: 20)),
                      title: Text(tx.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(_formatTime(tx.timestamp), style: const TextStyle(fontSize: 11)),
                      trailing: tx.amount > 0
                          ? Text('+₸${tx.amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                          : null,
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours < 24) return '${diff.inHours} ч назад';
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}';
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.greyColor)),
        ],
      ),
    );
  }
}

class _IncomeRow extends StatelessWidget {
  final PartnerProduct product;
  const _IncomeRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: NetworkOrBase64Image(
                imageUrl: product.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorWidget: Container(width: 48, height: 48, color: Colors.grey[200])),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${product.sold} шт × ₸${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppTheme.greyColor)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₸${product.revenue.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: product.revenue > 0 ? Colors.green : AppTheme.greyColor, fontSize: 15),
              ),
              if (product.sold > 0)
                Text(
                  '🔥 ${product.sold} продаж',
                  style: const TextStyle(fontSize: 10, color: AppTheme.greyColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
