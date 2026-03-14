import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/partner_provider.dart';
import '../../theme.dart';

class PartnerBalanceScreen extends StatelessWidget {
  const PartnerBalanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final partner = context.watch<PartnerProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text('Баланс', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 40),
                  const SizedBox(height: 12),
                  const Text('Доступный баланс', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('₸${partner.totalRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showWithdrawDialog(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF6C63FF)),
                          icon: const Icon(Icons.arrow_upward, size: 16),
                          label: const Text('Вывести'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Доходы по товарам
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Доходы по товарам', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
            ),
            const SizedBox(height: 16),
            if (partner.products.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.bar_chart, size: 64, color: AppTheme.greyColor.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      const Text('Нет данных о продажах', style: TextStyle(color: AppTheme.greyColor)),
                    ],
                  ),
                ),
              )
            else
              ...partner.products.map((p) => _IncomeRow(product: p)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Итого выручка', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textColor)),
                  Text('₸${partner.totalRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
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
      builder: (_) => AlertDialog(
        title: const Text('Вывод средств'),
        content: const Text('Функция вывода будет доступна после подключения платёжной системы.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Понятно'))],
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(product.imageUrl, width: 44, height: 44, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 44, height: 44, color: Colors.grey[200])),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${product.sold} шт × ₸${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppTheme.greyColor)),
              ],
            ),
          ),
          Text('₸${product.revenue.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
        ],
      ),
    );
  }
}
